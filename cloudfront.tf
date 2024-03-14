resource "aws_cloudfront_distribution" "ekscdn" {
  origin {
    domain_name = data.aws_elb.elbfood.dns_name
    origin_id   = "ELBOrigin"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id = "ELBOrigin"

    viewer_protocol_policy = "redirect-to-https"

    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    smooth_streaming       = false
   
   # Add SSL certificate from ACM
    viewer_certificate {
        acm_certificate_arn = aws_acm_certificate.cert.arn
        ssl_support_method  = "sni-only"
  }
}

output "cloudfront_distribution_arn" {
  value = aws_cloudfront_distribution.ekscdn.arn
}


output "cloudfront_url" {
  value = aws_cloudfront_distribution.ekscdn.domain_name
}
