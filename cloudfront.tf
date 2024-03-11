# Create CloudFront distribution
resource "aws_cloudfront_distribution" "eks_cloudfront_distribution" {
  depends_on = [aws_lb_target_group.eks_target_group]
  origin {
    domain_name = aws_lb_nlb.domain_name
    origin_id   = aws_lb_nlb.id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "eks_network_load_balancer"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "EKS CloudFront Distribution"
  default_root_object = "index.html"

  # Add SSL certificate from ACM
  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
  }

  tags = {
    Name = "eks-cloudfront-distribution"
  }
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.eks_cloudfront_distribution.domain_name
}
