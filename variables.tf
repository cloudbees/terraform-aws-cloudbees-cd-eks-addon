# Copyright (c) CloudBees, Inc.

variable "helm_config" {
  description = "CloudBees CD/RO Helm chart configuration."
  type        = any
  default = {
    values = [
      <<-EOT
      EOT
    ]
  }
}

variable "host_name" {
  description = "Amazon Route 53 hosted zone name."
  type        = string
  validation {
    condition     = trim(var.host_name, " ") != ""
    error_message = "Host name must not be en empty string."
  }
}

variable "cert_arn" {
  description = "AWS Certificate Manager (ACM) certificate for Amazon Resource Names (ARN)."
  type        = string

  validation {
    condition     = can(regex("^arn", var.cert_arn))
    error_message = "The cert_arn should start with arn."
  }
}

variable "flow_db_secrets_file" {
  description = "Secrets file a .yml path that contains the secrets names:values to create the Kubernetes secret flow_db_secret."
  default     = "flow_db_secrets-values.yml"
  type        = string
}
