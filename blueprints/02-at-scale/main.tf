data "aws_route53_zone" "this" {
  name = var.hosted_zone
}

data "aws_availability_zones" "available" {}

locals {

  name   = var.suffix == "" ? "cbcd-bp02" : "cbcd-bp02-${var.suffix}"
  region = "us-east-1"

  db_user_name = yamldecode(file("k8s/flow_db_secrets-values.yml")).DB_USER
  db_password  = yamldecode(file("k8s/flow_db_secrets-values.yml")).DB_PASSWORD

  vpc_name            = "${local.name}-vpc"
  cluster_name        = "${local.name}-eks"
  efs_name            = "${local.name}-efs"
  resource_group_name = "${local.name}-rg"
  bucket_name         = "${local.name}-s3"

  vpc_cidr = "10.0.0.0/16"

  #https://docs.cloudbees.com/docs/cloudbees-common/latest/supported-platforms/cloudbees-cd-k8s#_supported_kubernetes_versions
  k8s_version = "1.28"

  route53_zone_id  = data.aws_route53_zone.this.id
  route53_zone_arn = data.aws_route53_zone.this.arn
  #Number of AZs per region https://docs.aws.amazon.com/ram/latest/userguide/working-with-az-ids.html
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = merge(var.tags, {
    "tf-blueprint"  = local.name
    "tf-repository" = "github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon"
  })

  velero_s3_backup_location = "${module.cbcd_s3_bucket.s3_bucket_arn}/velero"
  velero_bk_demo            = "team-cd-bk"

}

################################################################################
# EKS: RDS
################################################################################

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "flow-db-${random_string.dbsuffix.result}"

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "14"
  family               = "postgres14" # DB parameter group
  major_engine_version = "14"         # DB option group
  instance_class       = "db.t4g.large"

  allocated_storage     = 20
  max_allocated_storage = 100

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  db_name                     = "flow"
  username                    = local.db_user_name
  password                    = local.db_password
  manage_master_user_password = false
  port                        = 5432

  # setting manage_master_user_password_rotation to false after it
  # has been set to true previously disables automatic rotation
  manage_master_user_password_rotation              = true
  master_user_password_rotate_immediately           = false
  master_user_password_rotation_schedule_expression = "rate(15 days)"

  multi_az               = true
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "psql-monitoring-role-name"
  monitoring_role_use_name_prefix       = true
  monitoring_role_description           = "Description for monitoring role"

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  tags = local.tags
  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
}

################################################################################
# EKS: Add-ons
################################################################################

# CloudBees CD Add-ons

module "eks_blueprints_addon_cbcd" {
  source = "../../"

  host_name = "${var.host_name}.${var.hosted_zone}"
  cert_arn  = module.acm.acm_certificate_arn

  helm_config = {
    create_namespace = false
    values = [templatefile("k8s/cbcd-values.yml", {
      host_name = "${var.host_name}.${var.hosted_zone}"
      cert_arn  = module.acm.acm_certificate_arn
      db_host   = module.db.db_instance_address
    })]
  }

  flow_db_secrets_file = "k8s/flow_db_secrets-values.yml"

  depends_on = [
    module.eks_blueprints_addons,
    module.db,
    module.efs
  ]
}

# EKS Blueprints Add-ons

module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.29.0"

  role_name_prefix = "${module.eks.cluster_name}-ebs-csi-driv"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = var.tags
}

#Issue 23
# data "aws_autoscaling_groups" "eks_node_groups" {
#   depends_on = [module.eks]
#   filter {
#     name   = "tag-key"
#     values = ["eks:cluster-name"]
#   }
# }

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.12.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  oidc_provider_arn = module.eks.oidc_provider_arn
  cluster_version   = module.eks.cluster_version

  eks_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
      # ensure any PVC created also includes the custom tags
      configuration_values = jsonencode(
        {
          controller = {
            extraVolumeTags = local.tags
          }
        }
      )
    }
    coredns    = {}
    vpc-cni    = {}
    kube-proxy = {}
  }
  #01-getting-started
  enable_external_dns = true
  external_dns = {
    values = [templatefile("k8s/extdns-values.yml", {
      zoneDNS = var.hosted_zone
    })]
  }
  external_dns_route53_zone_arns      = [local.route53_zone_arn]
  enable_aws_load_balancer_controller = true
  #02-at-scale
  enable_aws_efs_csi_driver = true
  enable_metrics_server     = true
  enable_cluster_autoscaler = true
  #Issue 23
  #enable_aws_node_termination_handler   = false
  #aws_node_termination_handler_asg_arns = data.aws_autoscaling_groups.eks_node_groups.arns
  enable_velero = true
  velero = {
    s3_backup_location = local.velero_s3_backup_location
    values             = [file("k8s/velero-values.yml")]
    iam_role_name      = "velero-iam-role"
  }

  tags = local.tags

  depends_on = [
    time_sleep.wait_60_seconds
  ]
}


################################################################################
# EKS: Infra
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name                   = local.cluster_name
  cluster_version                = local.k8s_version
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Security groups based on the best practices doc https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html.
  #   So, by default the security groups are restrictive. Users needs to enable rules for specific ports required for App requirement or Add-ons
  #   See the notes below for each rule used in these examples
  node_security_group_additional_rules = {
    # Recommended outbound traffic for Node groups
    egress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      self        = true
    }
    # Extend node-to-node security group rules. Recommended and required for the Add-ons
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }

    egress_ssh_all = {
      description      = "Egress all ssh to internet for github"
      protocol         = "tcp"
      from_port        = 22
      to_port          = 22
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    # Allows Control Plane Nodes to talk to Worker nodes on all ports. Added this to simplify the example and further avoid issues with Add-ons communication with Control plane.
    # This can be restricted further to specific port based on the requirement for each Add-on e.g., metrics-server 4443, spark-operator 8080, karpenter 8443 etc.
    # Change this according to your security requirements if needed
    ingress_cluster_to_node_all_traffic = {
      description                   = "Cluster API to Nodegroup all traffic"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  eks_managed_node_groups = {
    mg_start = {
      node_group_name = "managed-start"
      instance_types  = ["m5d.4xlarge"]
      capacity_type   = "ON_DEMAND"
      disk_size       = 25
      desired_size    = 2
    }
  }

  create_cloudwatch_log_group = false

  tags = local.tags
}

resource "kubernetes_storage_class_v1" "efs" {

  metadata {
    name = "efs"

    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "false"
    }
  }

  storage_provisioner = "efs.csi.aws.com"
  reclaim_policy      = "Delete"
  parameters = {
    provisioningMode = "efs-ap" # Dynamic provisioning
    fileSystemId     = module.efs.id
    directoryPerms   = "700"
    uid : "1000"
    gid : "1000"
  }

  mount_options = [
    "iam"
  ]
}

resource "null_resource" "create_kubeconfig" {

  depends_on = [module.eks]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${local.region}"
  }
}

################################################################################
# Supported Resources
################################################################################

module "efs" {
  source  = "terraform-aws-modules/efs/aws"
  version = "1.2.0"

  creation_token = local.efs_name
  name           = local.efs_name

  mount_targets = {
    for k, v in zipmap(local.azs, module.vpc.private_subnets) : k => { subnet_id = v }
  }
  security_group_description = "${local.efs_name} EFS security group"
  security_group_vpc_id      = module.vpc.vpc_id

  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"
  security_group_rules = {
    vpc = {
      # relying on the defaults provdied for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = module.vpc.private_subnets_cidr_blocks
    }
  }

  # Backup policy
  enable_backup_policy = true

  tags = var.tags
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "4.3.2"

  #Important: Application Services Hostname must be the same as the domain name or subject_alternative_names
  domain_name = "${var.host_name}.${var.hosted_zone}"

  #https://docs.aws.amazon.com/acm/latest/userguide/dns-validation.html
  zone_id = local.route53_zone_id

  tags = local.tags
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = local.vpc_name
  cidr = local.vpc_cidr

  azs              = local.azs
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 96)]

  create_database_subnet_group = true
  enable_nat_gateway           = true
  single_nat_gateway           = true

  #https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
  #https://docs.aws.amazon.com/eks/latest/userguide/network-load-balancing.html
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags

}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = local.name
  description = "Complete PostgreSQL example security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = local.tags
}

resource "aws_resourcegroups_group" "bp_rg" {
  name = local.resource_group_name

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "tf-blueprint",
      "Values": ["${local.name}"]
    }
  ]
}
JSON
  }
}

module "cbcd_s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = local.bucket_name

  # Allow deletion of non-empty bucket
  # NOTE: This is enabled for example usage only, you should not enable this for production workloads
  force_destroy = true

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  acl = "private"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  #SECO-3109
  object_lock_enabled = false

  versioning = {
    status     = true
    mfa_delete = false
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = local.tags
}

resource "random_string" "dbsuffix" {
  length  = 4
  upper   = false
  lower   = true
  special = false
}

# Need to wait a few seconds when before setup the eks addons

resource "time_sleep" "wait_60_seconds" {
  depends_on       = [module.eks]
  destroy_duration = "60s"
}