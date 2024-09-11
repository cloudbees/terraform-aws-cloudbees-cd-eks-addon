
output "kubeconfig_export" {
  description = "Exports the KUBECONFIG environment variable to access the Kubernetes API."
  value       = "export KUBECONFIG=${local.kubeconfig_file_path}"
}

output "kubeconfig_add" {
  description = "Adds Kubeconfig to your local configuration to access the Kubernetes API."
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
  description = "Retrieves the admin password for the CloudBees CD/RO add-on."
  value       = module.eks_blueprints_addon_cbcd.cbcd_password
}

output "acm_certificate_arn" {
  description = "AWS Certificate Manager (ACM) certificate for Amazon Resource Names (ARN)."
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
