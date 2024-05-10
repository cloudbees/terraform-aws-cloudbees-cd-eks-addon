output "kubeconfig_export" {
  description = "Export KUBECONFIG environment variable to access to access the K8s API."
  value       = "export KUBECONFIG=${local.kubeconfig_file_path}"
}

output "kubeconfig_add" {
  description = "Add Kubeconfig to local configuration to access the K8s API."
  value       = "aws eks update-kubeconfig --region ${local.region} --name ${local.cluster_name}"
}

output "cbcd_helm" {
  description = "Helm configuration for CloudBees CD Add-on. It is accesible only via state files."
  value       = module.eks_blueprints_addon_cbcd.merged_helm_config
  sensitive   = true
}

output "cbcd_namespace" {
  description = "Namespace for CloudBees CD Add-on."
  value       = module.eks_blueprints_addon_cbcd.cbcd_namespace
}

output "cbcd_url" {
  description = "URL of the CloudBees CD Operations Center for CloudBees CD Add-on."
  value       = module.eks_blueprints_addon_cbcd.cbcd_url
}

output "cbcd_password" {
  description = "command to get the admin password of Cloudbees CD"
  value       = module.eks_blueprints_addon_cbcd.cbcd_password
}

output "rds_instance_id" {
  description = "DB identifier for CloudBees CD Add-on."
  value       = local.rds_instance_id
}

output "rds_snapshot_id" {
  description = "DB snapshot identifier for CloudBees CD Add-on."
  value       = local.rds_snapshot_id
}

output "rds_arn" {
  description = "DB ARN for CloudBees CD Add-on."
  value       = module.db.db_instance_arn
}

output "rds_backup_cmd" {
  description = "command to do DB backup."
  value       = "aws rds create-db-snapshot --db-instance-identifier ${local.rds_instance_id} --db-snapshot-identifier ${local.rds_snapshot_id}"
}

output "rds_restore_cmd" {
  description = "command to do DB restore from snapshot."
  value       = "aws rds restore-db-instance-from-db-snapshot --db-instance-identifier ${local.rds_instance_id} --db-snapshot-identifier ${local.rds_snapshot_id}"
}

output "acm_certificate_arn" {
  description = "ACM certificate ARN"
  value       = module.acm.acm_certificate_arn
}

output "vpc_arn" {
  description = "VPC ID"
  value       = module.vpc.vpc_arn
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "s3_cbcd_arn" {
  description = "cbcd s3 Bucket Arn"
  value       = module.cbcd_s3_bucket.s3_bucket_arn
}

output "s3_cbcd_name" {
  description = "cbcd s3 Bucket Name. It is required by Velero for backup"
  value       = local.bucket_name
}

output "efs_access_points" {
  description = "EFS Access Points."
  value       = "aws efs describe-access-points --file-system-id ${module.efs.id} --region ${local.region}"
}

output "cbcd_ing" {
  description = "CD Ingress for the CloudBees CI add-on."
  value       = module.eks_blueprints_addon_cbcd.cbcd_ing
}

output "cbcd_liveness_probe_int" {
  description = "CD service internal liveness probe for the CloudBees CD add-on."
  value       = module.eks_blueprints_addon_cbcd.cbcd_liveness_probe_int
}

output "velero_backup_schedule_team_cd" {
  description = "Create velero backup schedulle for Team A, deleting existing one (if exists). It can be applied for other controllers using EBS."
  value       = "velero schedule delete ${local.velero_bk_demo} --confirm || true; velero create schedule ${local.velero_bk_demo} --schedule='@every 30m' --ttl 2h --include-namespaces ${module.eks_blueprints_addon_cbcd.cbcd_namespace} --exclude-resources events,events.events.k8s.io"
}

output "velero_backup_on_demand_team_cd" {
  description = "Take an on-demand velero backup from the schedulle for Team CD. "
  value       = "velero backup create --from-schedule ${local.velero_bk_demo} --wait"
}

output "velero_restore_team_cd" {
  description = "Restore Team A from backup. It can be applicable for rest of schedulle backups."
  value       = "kubectl delete all -n ${module.eks_blueprints_addon_cbcd.cbcd_namespace}; kubectl delete pvc -n ${module.eks_blueprints_addon_cbcd.cbcd_namespace}; kubectl delete ep -n ${module.eks_blueprints_addon_cbcd.cbcd_namespace}; velero restore create --from-schedule ${local.velero_bk_demo}"
}
