
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
  description = "Command to get the admin password of Cloudbees CD"
  value       = "module.eks_blueprints_addon_cbcd.cbcd_password"
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
