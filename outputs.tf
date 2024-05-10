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
  value       = "kubectl get secret --namespace ${local.namespace} cloudbees-cd-cloudbees-flow-credentials -o jsonpath='{.data.CBF_SERVER_ADMIN_PASSWORD}' | base64 -d; echo"
}

output "cbcd_domain_name" {
  description = "Route 53 Domain Name to host CloudBees CD Services."
  value       = var.host_name
}

output "cbcd_flowserver_pod" {
  description = "Flow Server Pod for CloudBees CD Add-on."
  value       = "kubectl get pods -l app=flow-server -n ${helm_release.cloudbees_cd.namespace}"
}

output "cbcd_ing" {
  description = "Ingress for the CloudBees CD add-on."
  value       = "kubectl get ing -n ${helm_release.cloudbees_cd.namespace} flow-ingress"
}

output "cbcd_liveness_probe_int" {
  description = "CD service internal liveness probe for the CloudBees CD add-on."
  value       = "kubectl exec -n ${helm_release.cloudbees_cd.namespace} -ti $(kubectl get pods -l app=flow-server  -n ${helm_release.cloudbees_cd.namespace} --output=jsonpath={.items..metadata.name}) --container flow-server -- /opt/cbflow/health-check > /dev/null"
}
