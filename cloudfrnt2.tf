
# Update CloudFront distribution to point to NLB
resource "aws_cloudfront_distribution" "eks_cloudfront_distribution2" {
  origin {
    domain_name = data.aws_elb.elbfood2.dns_name
    origin_id   = "data.aws_elb.elbfood2"

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
    target_origin_id = "data.aws_elb.elbfood2"

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
  comment             = "EKS CloudFront Distribution2"
  default_root_object = "index.html"

  # Add SSL certificate from ACM
  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
  }

  tags = {
    Name = "eks-cloudfront-distribution2"
  }
}


output "cloudfront_distribution2_arn" {
  value = aws_cloudfront_distribution.eks_cloudfront_distribution2.arn
}


output "cloudfront_url2" {
  value = aws_cloudfront_distribution.eks_cloudfront_distribution2.domain_name
}
