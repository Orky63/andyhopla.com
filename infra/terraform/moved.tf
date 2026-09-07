# Retain production resources when removing the temporary counted staging configuration.
# Keep these blocks so existing state can migrate safely during a reviewed apply.

moved {
  from = aws_acm_certificate_validation.site[0]
  to   = aws_acm_certificate_validation.site
}

moved {
  from = aws_cloudfront_distribution.site[0]
  to   = aws_cloudfront_distribution.site
}

moved {
  from = aws_cloudfront_function.www_redirect[0]
  to   = aws_cloudfront_function.www_redirect
}

moved {
  from = aws_cloudfront_origin_access_control.site[0]
  to   = aws_cloudfront_origin_access_control.site
}

moved {
  from = aws_cloudfront_response_headers_policy.site[0]
  to   = aws_cloudfront_response_headers_policy.site
}

moved {
  from = aws_s3_bucket_policy.content[0]
  to   = aws_s3_bucket_policy.content
}
