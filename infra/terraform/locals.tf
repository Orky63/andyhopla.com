locals {
  name    = "${var.project_name}-${var.environment}"
  domains = [var.domain_name, "www.${var.domain_name}"]
  tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
  origin_id = "${local.name}-s3"
}
