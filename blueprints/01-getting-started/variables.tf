
variable "tags" {
  description = "Tags to apply to resources"
  default     = {}
  type        = map(string)
}

variable "hosted_zone" {
  description = "Route 53 Hosted Zone. CloudBees CD Apps is configured to use this hosted zone."
  type        = string
}

variable "suffix" {
  description = "Unique suffix to be assigned to all resources"
  default     = ""
  type        = string
  validation {
    condition     = length(var.suffix) <= 10
    error_message = "The suffix cannot have more than 10 characters."
  }
}
