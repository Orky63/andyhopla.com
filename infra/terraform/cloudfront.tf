resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "${local.name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_function" "www_redirect" {
  name    = "${local.name}-www-redirect"
  runtime = "cloudfront-js-2.0"
  comment = "Redirect www to the canonical apex, preserving path and query values"
  publish = true
  code    = <<-JS
    function handler(event) {
      var request = event.request;
      if (request.headers.host.value !== ${jsonencode("www.${var.domain_name}")}) {
        return request;
      }
      var pairs = [];
      var query = request.querystring || {};
      // CloudFront supplies URL-encoded query components: retain their encoding.
      for (var key in query) {
        var values = query[key].multiValue || [query[key]];
        for (var i = 0; i < values.length; i++) {
          pairs.push(key + '=' + values[i].value);
        }
      }
      var location = 'https://' + ${jsonencode(var.domain_name)} + request.uri;
      if (pairs.length) location += '?' + pairs.join('&');
      return {
        statusCode: 301,
        statusDescription: 'Moved Permanently',
        headers: {
          location: { value: location },
          'cache-control': { value: 'max-age=300' }
        }
      };
    }
  JS
}

resource "aws_cloudfront_response_headers_policy" "site" {
  name = "${local.name}-security-headers"
  security_headers_config {
    content_type_options { override = true }
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }
    # Short initial HSTS lifetime; no preload or includeSubDomains during migration.
    strict_transport_security {
      access_control_max_age_sec = 300
      include_subdomains         = false
      preload                    = false
      override                   = true
    }
  }
}

resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${local.name} static portfolio"
  default_root_object = "index.html"
  aliases             = local.domains
  price_class         = "PriceClass_100"
  http_version        = "http2and3"
  wait_for_deployment = true

  # Private S3 returns 403 for missing keys when ListBucket is not granted.
  # CloudFront requires a real response page when overriding the status code.
  custom_error_response {
    error_code            = 403
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 10
  }

  origin {
    domain_name              = aws_s3_bucket.content.bucket_regional_domain_name
    origin_id                = local.origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    target_origin_id       = local.origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    # AWS managed CachingOptimized policy. Set object cache metadata at deployment.
    cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.site.id
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.www_redirect.arn
    }
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.site.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
