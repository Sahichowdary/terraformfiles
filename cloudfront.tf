# Update CloudFront distribution to point to NLB
resource "aws_cloudfront_distribution" "eks_cloudfront_distribution" {
  origin {
    domain_name = aws_lb.nlb.dns_name
    origin_id   = aws_lb.nlb.id

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


# Update NLB security group to allow traffic from CloudFront
resource "aws_security_group_rule" "cloudfront_to_nlb" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "HTTPS"
  security_group_id = aws_security_group.nlb_sg.id
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.eks_cloudfront_distribution.domain_name
}
