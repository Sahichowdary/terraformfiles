resource "aws_cloudfront_distribution" "ekscdn" {
  origin {
    domain_name = data.aws_elb.elbfood.dns_name
    origin_id   = data.aws_elb.elbfood.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id       = data.aws_elb.elbfood.id
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl          = 0
    default_ttl      = 3600
    max_ttl          = 86400
    compress         = true
    smooth_streaming = false
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}

output "cloudfront_distribution_arn" {
  value = aws_cloudfront_distribution.ekscdn.arn
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.ekscdn.domain_name
}
