# CloudBees CD/RO blueprint add-on: At scale

Once you have familiarized yourself with the [CloudBees CD/RO blueprint: Get started](../01-getting-started/README.md), this blueprint presents a scalable architecture and configuration by adding:

- An [RDS](https://aws.amazon.com/rds/) that can be used by CloudBees CD/RO as database server. 
- An [Amazon Elastic File System (Amazon EFS) drive](https://aws.amazon.com/efs/) that can be used by CloudBees CD/RO for cluster setup. It is managed by [Amazon Web Services (AWS) Backup](https://aws.amazon.com/backup/) for backup and restore.
- An [Amazon S3 bucket](https://aws.amazon.com/s3/) to store assets from applications, such as Velero.
- [Amazon Elastic Kubernetes Service (Amazon EKS) managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) for CloudBees CD/RO applications.
- The following [Amazon EKS blueprints add-ons](https://aws-ia.github.io/terraform-aws-eks-blueprints-addons/main/):

  | Amazon EKS blueprints add-ons | Description |
  |-------------------------------|-------------|
  | [AWS EFS CSI Driver](https://aws-ia.github.io/terraform-aws-eks-blueprints-addons/main/addons/aws-efs-csi-driver/)| Connects the Amazon EFS drive to the Amazon EKS cluster. |
  | [Cluster Autoscaler](https://aws-ia.github.io/terraform-aws-eks-blueprints-addons/main/addons/cluster-autoscaler/) | Watches Amazon EKS managed node groups to accomplish CloudBees CD/RO auto-scaling nodes on EKS. |
  | [Metrics Server](https://aws-ia.github.io/terraform-aws-eks-blueprints-addons/main/addons/metrics-server/) | This is required by CloudBees CD/RO for horizontal pod autoscaling.|
  | [Velero](https://aws-ia.github.io/terraform-aws-eks-blueprints-addons/main/addons/velero/)| Backs up and restores Kubernetes resources and volume snapshots. It is only compatible with Amazon Elastic Block Store (Amazon EBS).|

> [!TIP]
> A [resource group](https://docs.aws.amazon.com/ARG/latest/userguide/resource-groups.html) is also included, to get a full list of all resources created by this blueprint.

## Architecture

![Architecture](img/at-scale.architect.drawio.svg)

### Kubernetes cluster

![Architecture](img/at-scale.k8s.drawio.svg)

## Terraform documentation

<!-- BEGIN_TF_DOCS -->
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| host_name | Host name. CloudBees CD Apps is configured to use this host name. | `string` | n/a | yes |
| hosted_zone | Route 53 Hosted Zone. CloudBees CD is configured to use subdomains in this Hosted Zone. | `string` | n/a | yes |
| suffix | Unique suffix to be assigned to all resources | `string` | `""` | no |
| tags | Tags to apply to resources. | `map(string)` | `{}` | no |

### Outputs

| Name | Description |
|------|-------------|
| acm_certificate_arn | ACM certificate ARN |
| cbcd_helm | Helm configuration for CloudBees CD Add-on. It is accesible only via state files. |
| cbcd_ing | CD Ingress for the CloudBees CI add-on. |
| cbcd_liveness_probe_int | CD service internal liveness probe for the CloudBees CD add-on. |
| cbcd_namespace | Namespace for CloudBees CD Add-on. |
| cbcd_password | command to get the admin password of Cloudbees CD |
| cbcd_url | URL of the CloudBees CD Operations Center for CloudBees CD Add-on. |
| efs_access_points | EFS Access Points. |
| eks_cluster_arn | EKS cluster ARN |
| kubeconfig_add | Add Kubeconfig to local configuration to access the K8s API. |
| kubeconfig_export | Export KUBECONFIG environment variable to access to access the K8s API. |
| rds_arn | DB ARN for CloudBees CD Add-on. |
| rds_backup_cmd | command to do DB backup. |
| rds_instance_id | DB identifier for CloudBees CD Add-on. |
| rds_restore_cmd | command to do DB restore from snapshot. |
| rds_snapshot_id | DB snapshot identifier for CloudBees CD Add-on. |
| s3_cbcd_arn | cbcd s3 Bucket Arn |
| s3_cbcd_name | cbcd s3 Bucket Name. It is required by Velero for backup |
| velero_backup_on_demand_team_cd | Take an on-demand velero backup from the schedulle for Team CD. |
| velero_backup_schedule_team_cd | Create velero backup schedulle for Team A, deleting existing one (if exists). It can be applied for other controllers using EBS. |
| velero_restore_team_cd | Restore Team A from backup. It can be applicable for rest of schedulle backups. |
| vpc_arn | VPC ID |
<!-- END_TF_DOCS -->

## Deploy

When preparing to deploy, you must complete the following steps:

1. Customize your Terraform values by copying `.auto.tfvars.example` to `.auto.tfvars`.
1. Customize your secrets file by copying `flow_db_secrets-values.yml.example` to `flow_db_secrets-values.yml`.
1. If using the Terraform variable `suffix` for this blueprint, the Amazon `S3 Bucket Access settings` > `S3 Bucket Name` must be updated.
1. Initialize the root module and any associated configuration for providers.
1. Create the resources and deploy CloudBees CD/RO to an EKS cluster. Refer to [Amazon EKS Blueprints for Terraform - Deploy](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#deploy).

For more information, refer to [The Core Terraform Workflow](https://www.terraform.io/intro/core-workflow) documentation.

## Validate

Once the blueprint has been deployed, you can validate it.

### Kubeconfig

Once the resources have been created, a `kubeconfig` file is created in the [/k8s](k8s) folder. Issue the following command to define the [KUBECONFIG](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#the-kubeconfig-environment-variable) environment variable to point to the newly generated file:

  ```sh
  eval $(terraform output --raw kubeconfig_export)
  ```

If the command is successful, no output is returned.

### CloudBees CD/RO

Once you can access the Kubernetes API from your terminal, complete the following steps.

1. DNS propagation may take several minutes. Once propagation is complete, issue the following command:

      ```sh
      terraform output cbcd_url
      ```
1. To access CloudBees CD/RO, paste the output of the previous command into a web browser.
1. Issue the following command to retrieve the initial administrative user password to sign in to CloudBees CD/RO:

      ```sh
      eval $(terraform output --raw cbcd_password)
      ```
### Back up and restore

#### Back up and restore database storage using Amazon Relational Database Service (Amazon RDS)

1. Issue the following command to create a snapshot of the Amazon RDS instance:

    ```sh
    eval $(terraform output -raw rds_backup_cmd)
    ```
1. Issue the following command to restore the RDS instance from the snapshot:

    ```sh
    eval $(terraform output -raw rds_restore_cmd)
    ```

#### Back up and restore using Velero

1. Issue the following command to create a Velero backup schedule for `Team CD`:

    ```sh
    eval $(terraform output --raw velero_backup_schedule_team_cd)
    ```
1. Issue the following command to take an on-demand Velero backup for a specific point in time for `Team CD` based on the schedule definition:

    ```sh
    eval $(terraform output --raw velero_backup_on_demand_team_cd)
    ```
   
1. Issue the following command to restore from the last backup:

    ```sh
    eval $(terraform output --raw velero_restore_team_cd)
    ```

   1. Issue the following command to restore from an Amazon EFS access point, that matches the CloudBees CD/RO PVC:

      ```sh
      eval $(terraform output --raw efs_access_points) | . jq .AccessPoints[].RootDirectory.Path
      ```

## Destroy

To tear down and remove the resources created in the blueprint, complete the steps for [Amazon EKS Blueprints for Terraform - Destroy](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#destroy).

> [!TIP]
> The `destroy` phase can be orchestrated via the companion [Makefile](../../Makefile).