output "route53_hosted_zone_id" {
  description = "New public hosted zone; not authoritative until registrar delegation changes."
  value       = aws_route53_zone.site.zone_id
}
output "route53_nameservers" {
  description = "Do NOT set at Hostinger until website deployment, testing and DNS inventory checks pass."
  value       = aws_route53_zone.site.name_servers
}
output "s3_bucket_name" {
  value = aws_s3_bucket.content.id
}
output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.site.id
}
output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.site.domain_name
}
output "acm_certificate_arn" {
  value = aws_acm_certificate.site.arn
}
output "acm_dns_validation_records" {
  description = "Add these exact CNAMEs to Hostinger while it remains authoritative; keep in both DNS providers."
  value = {
    for option in aws_acm_certificate.site.domain_validation_options : option.domain_name => {
      name  = option.resource_record_name
      type  = option.resource_record_type
      value = option.resource_record_value
    }
  }
}
output "canonical_website_hostname" {
  value = var.domain_name
}
