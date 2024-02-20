
output "kubeconfig_export" {
  description = "Export KUBECONFIG environment variable to access the K8s API."
  value       = "export KUBECONFIG=${local.kubeconfig_file_path}"
}

output "kubeconfig_add" {
  description = "Add Kubeconfig to local configuration to access the K8s API."
  value       = "aws eks update-kubeconfig --region ${local.region} --name ${local.cluster_name}"
}

output "cbcd_helm" {
  description = "Helm configuration for CloudBees CI Add-on. It is accesible only via state files."
  value       = module.eks_blueprints_addon_cbcd.merged_helm_config
  sensitive   = true
}

output "cbcd_namespace" {
  description = "Namespace for CloudBees CI Add-on."
  value       = module.eks_blueprints_addon_cbcd.cbcd_namespace
}

output "cbcd_general_password" {
  description = "Operation Center Service Initial Admin Password for CloudBees CI Add-on. Additionally, there are developer and guest users using the same password."
  value       = "kubectl get secret cbcd-secrets -n ${module.eks_blueprints_addon_cbcd.cbcd_namespace} -o jsonpath='{.data.secJenkinsPass}' | base64 -d"
}

output "cbcd_url" {
  description = "URL of the CloudBees CI Operations Center for CloudBees CI Add-on."
  value       = module.eks_blueprints_addon_cbcd.cbcd_url
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

output "efs_arn" {
  description = "EFS ARN."
  value       = module.efs.arn
}

output "efs_access_points" {
  description = "EFS Access Points."
  value       = "aws efs describe-access-points --file-system-id ${module.efs.id} --region ${local.region}"
}

output "aws_backup_efs_protected_resource" {
  description = "AWS Backup Protected Resource descriction for EFS Drive."
  value       = "aws backup describe-protected-resource --resource-arn ${module.efs.arn} --region ${local.region}"
}

output "velero_backup_schedule_team_a" {
  description = "Create velero backup schedulle for Team A, deleting existing one (if exists). It can be applied for other controllers using EBS."
  value       = "velero schedule delete ${local.velero_bk_demo} --confirm || true; velero create schedule ${local.velero_bk_demo} --schedule='@every 30m' --ttl 2h --include-namespaces ${module.eks_blueprints_addon_cbcd.cbcd_namespace} --exclude-resources pods,events,events.events.k8s.io --selector tenant=team-a"
}

output "velero_backup_on_demand_team_a" {
  description = "Take an on-demand velero backup from the schedulle for Team A. "
  value       = "velero backup create --from-schedule ${local.velero_bk_demo} --wait"
}

output "velero_restore_team_a" {
  description = "Restore Team A from backup. It can be applicable for rest of schedulle backups."
  value       = "kubectl delete all -n ${module.eks_blueprints_addon_cbcd.cbcd_namespace} -l tenant=team-a; kubectl delete pvc -n ${module.eks_blueprints_addon_cbcd.cbcd_namespace} -l tenant=team-a; kubectl delete ep -n ${module.eks_blueprints_addon_cbcd.cbcd_namespace} -l tenant=team-a; velero restore create --from-schedule ${local.velero_bk_demo}"
}