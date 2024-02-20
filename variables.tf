# Copyright (c) CloudBees, Inc.

variable "helm_config" {
  description = "CloudBees CD Helm chart configuration"
  type        = any
  default = {
    values = [
      <<-EOT
      EOT
    ]
  }
}

variable "host_name" {
  description = "Route53 Host name"
  type        = string
  validation {
    condition     = trim(var.host_name, " ") != ""
    error_message = "Host name must not be en empty string."
  }
}

variable "cert_arn" {
  description = "Certificate ARN from AWS ACM"
  type        = string

  validation {
    condition     = can(regex("^arn", var.cert_arn))
    error_message = "For the cert_arn should start with arn."
  }
}

variable "flow_admin_secrets_file" {
  description = "Secrets file yml path containing the secrets names:values to create the Kubernetes secret flow_admin_secret."
  default     = "flow_admin_secrets-values.yml"
  type        = string
}

variable "flow_db_secrets_file" {
  description = "Secrets file yml path containing the secrets names:values to create the Kubernetes secret flow_db_secret."
  default     = "flow_db_secrets-values.yml"
  type        = string
}
