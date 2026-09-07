variable "project_name" {
  description = "Short lowercase resource naming prefix."
  type        = string
  default     = "andyhopla"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,19}$", var.project_name))
    error_message = "Use 1–20 lowercase letters, digits or hyphens, starting with a letter."
  }
}

variable "environment" {
  description = "Deployment environment used in names and tags."
  type        = string
  default     = "prod"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,9}$", var.environment))
    error_message = "Use 1–10 lowercase letters, digits or hyphens, starting with a letter."
  }
}

variable "domain_name" {
  description = "Canonical apex hostname, without scheme, www prefix or trailing dot."
  type        = string
  default     = "andyhopla.com"
  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$", var.domain_name)) && !startswith(var.domain_name, "www.") && length(var.domain_name) <= 253
    error_message = "Provide a lowercase apex hostname without a scheme, www prefix or trailing dot."
  }
}

variable "aws_region" {
  description = "Primary region for the content bucket; ACM is always us-east-1."
  type        = string
  default     = "eu-west-2"
}

variable "tags" {
  description = "Additional resource tags; required project tags take precedence."
  type        = map(string)
  default     = {}
}
