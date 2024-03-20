# Copyright (c) CloudBees, Inc.

output "merged_helm_config" {
  description = "(merged) Helm Config for CloudBees CD"
  value       = helm_release.cloudbees_cd
}

output "cbcd_namespace" {
  description = "Namespace for CloudBees CD Addon."
  value       = helm_release.cloudbees_cd.namespace
}

output "cbcd_url" {
  description = "URL for CloudBees CD Add-on."
  value       = "https://${var.host_name}"
}

output "cbcd_password" {
  description = "Command to get the admin password of Cloudbees CD"
  value       = "kubectl get secret --namespace ${local.namespace} cloudbees-cd-cloudbees-flow-credentials -o jsonpath='{.data.CBF_SERVER_ADMIN_PASSWORD}' | base64 --decode; echo"
}

output "cbcd_domain_name" {
  description = "Route 53 Domain Name to host CloudBees CD Services."
  value       = var.host_name
}

output "cbcd_flowserver_pod" {
  description = "Flow Server Pod for CloudBees CD Add-on."
  value       = "kubectl get pods -l app=flow-server -n ${helm_release.cloudbees_cd.namespace}"
}

