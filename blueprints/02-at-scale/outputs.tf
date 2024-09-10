output "kubeconfig_export" {
  description = "Export the KUBECONFIG environment variable to access the Kubernetes API."
  value       = "export KUBECONFIG=${local.kubeconfig_file_path}"
}

output "kubeconfig_add" {
  description = "Add kubeconfig to your local configuration to access the Kubernetes API."
  value       = "aws eks update-kubeconfig --region ${local.region} --name ${local.cluster_name}"
}

output "cbcd_helm" {
  description = "Helm configuration for the CloudBees CD/RO add-on. It is accessible via state files only."
  value       = module.eks_blueprints_addon_cbcd.merged_helm_config
  sensitive   = true
}

output "cbcd_namespace" {
  description = "Namespace for the CloudBees CD/RO add-on."
  value       = module.eks_blueprints_addon_cbcd.cbcd_namespace
}

output "cbcd_url" {
  description = "URL of the CloudBees CD/RO server for the CloudBees CD/RO add-on."
  value       = module.eks_blueprints_addon_cbcd.cbcd_url
}

output "cbcd_password" {
  description = "Retrieve the administrator password for CloudBees CD/RO."
  value       = module.eks_blueprints_addon_cbcd.cbcd_password
}

output "rds_instance_id" {
  description = "Database identifier for the CloudBees CD/RO add-on."
  value       = local.rds_instance_id
}

output "rds_snapshot_id" {
  description = "Database snapshot identifier for the CloudBees CD/RO add-on."
  value       = local.rds_snapshot_id
}

output "rds_arn" {
  description = "Database Amazon Resource Names (ARN) for the CloudBees CD/RO add-on."
  value       = module.db.db_instance_arn
}

output "rds_backup_cmd" {
  description = "Perform a database backup."
  value       = "aws rds create-db-snapshot --db-instance-identifier ${local.rds_instance_id} --db-snapshot-identifier ${local.rds_snapshot_id}"
}

output "rds_restore_cmd" {
  description = "Perform a database restore from a snapshot."
  value       = "aws rds restore-db-instance-from-db-snapshot --db-instance-identifier ${local.rds_instance_id} --db-snapshot-identifier ${local.rds_snapshot_id}"
}

output "acm_certificate_arn" {
  description = "AWS Certificate Manager (ACM) certificate for ARN."
  value       = module.acm.acm_certificate_arn
}

output "vpc_arn" {
  description = "VPC ID."
  value       = module.vpc.vpc_arn
}

output "eks_cluster_arn" {
  description = "Amazon EKS cluster ARN."
  value       = module.eks.cluster_arn
}

output "s3_cbcd_arn" {
  description = "CloudBees CD/RO Amazon S3 bucket ARN."
  value       = module.cbcd_s3_bucket.s3_bucket_arn
}

output "s3_cbcd_name" {
  description = "CloudBees CD/RO Amazon S3 bucket name; it is required by Velero for the backup."
  value       = local.bucket_name
}

output "efs_access_points" {
  description = "Amazon EFS access points."
  value       = "aws efs describe-access-points --file-system-id ${module.efs.id} --region ${local.region}"
}

output "cbcd_ing" {
  description = "CloudBees CD/RO Ingress for the CloudBees CD/RO add-on."
  value       = module.eks_blueprints_addon_cbcd.cbcd_ing
}

output "cbcd_liveness_probe_int" {
  description = "CloudBees CD/RO service internal liveness probe for the CloudBees CD/RO add-on."
  value       = module.eks_blueprints_addon_cbcd.cbcd_liveness_probe_int
}

output "velero_backup_schedule_team_cd" {
  description = "Creates a Velero backup schedule for Team CD; delete the existing backup if one already exists."
  value       = "velero schedule delete ${local.velero_bk_demo} --confirm || true; velero create schedule ${local.velero_bk_demo} --schedule='@every 30m' --ttl 2h --include-namespaces ${module.eks_blueprints_addon_cbcd.cbcd_namespace} --exclude-resources events,events.events.k8s.io"
}

output "velero_backup_on_demand_team_cd" {
  description = "Takes an on-demand Velero backup from the schedule for Team CD. "
  value       = "velero backup create --from-schedule ${local.velero_bk_demo} --wait"
}

output "velero_restore_team_cd" {
  description = "Restores Team CD from a backup. It can be applicable to any subsequent scheduled backups."
  value       = "kubectl delete all -n ${module.eks_blueprints_addon_cbcd.cbcd_namespace}; kubectl delete pvc -n ${module.eks_blueprints_addon_cbcd.cbcd_namespace}; kubectl delete ep -n ${module.eks_blueprints_addon_cbcd.cbcd_namespace}; velero restore create --from-schedule ${local.velero_bk_demo}"
}
