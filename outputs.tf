# Copyright (c) CloudBees, Inc.

output "merged_helm_config" {
  description = "(merged) Helm configuration for CloudBees CD/RO."
  value       = helm_release.cloudbees_cd
}

output "cbcd_namespace" {
  description = "Namespace for the CloudBees CD/RO add-on."
  value       = helm_release.cloudbees_cd.namespace
}

output "cbcd_url" {
  description = "URL for the CloudBees CD/RO add-on."
  value       = "https://${var.host_name}"
}

output "cbcd_password" {
  description = "Retrieves the admin password of CloudBees CD/RO."
  value       = "kubectl get secret --namespace ${local.namespace} cloudbees-cd-cloudbees-flow-credentials -o jsonpath='{.data.CBF_SERVER_ADMIN_PASSWORD}' | base64 -d; echo"
}

output "cbcd_domain_name" {
  description = "Amazon Route 53 domain name to host CloudBees CD/RO Services."
  value       = var.host_name
}

output "cbcd_flowserver_pod" {
  description = "Flow server pod for the CloudBees CD/RO add-on."
  value       = "kubectl get pods -l app=flow-server -n ${helm_release.cloudbees_cd.namespace}"
}

output "cbcd_ing" {
  description = "Ingress for the CloudBees CD/RO add-on."
  value       = "kubectl get ing -n ${helm_release.cloudbees_cd.namespace} flow-ingress"
}

output "cbcd_liveness_probe_int" {
  description = "CloudBees CD/RO service internal liveness probe for the CloudBees CD/RO add-on."
  value       = "kubectl exec -n ${helm_release.cloudbees_cd.namespace} -ti $(kubectl get pods -l app=flow-server  -n ${helm_release.cloudbees_cd.namespace} --output=jsonpath={.items..metadata.name}) --container flow-server -- /opt/cbflow/health-check > /dev/null"
}
