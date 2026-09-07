resource "aws_route53_zone" "site" {
  name    = var.domain_name
  comment = "${local.name}: final AWS zone; do not delegate before deployment and testing"
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for option in aws_acm_certificate.site.domain_validation_options : option.domain_name => {
      name  = option.resource_record_name
      type  = option.resource_record_type
      value = option.resource_record_value
    }
  }
  zone_id = aws_route53_zone.site.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 300
  records = [each.value.value]
}

# Production apex and www routing.
resource "aws_route53_record" "website_ipv4" {
  for_each = toset(local.domains)
  zone_id  = aws_route53_zone.site.zone_id
  name     = each.value
  type     = "A"
  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "website_ipv6" {
  for_each = toset(local.domains)
  zone_id  = aws_route53_zone.site.zone_id
  name     = each.value
  type     = "AAAA"
  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}
