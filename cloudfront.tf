# Create CloudFront distribution
resource "aws_cloudfront_distribution" "eks_cloudfront_distribution" {
  origin {
    domain_name = a173699949b2a4516bfebfa05d007725-1712453856.ap-southeast-2.elb.amazonaws.com
    origin_id   = "eks_network_load_balancer"

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

resource "aws_lb" "eks_network_load_balancer" {
  name               = "eks-network-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.private-us-east-1b.id, aws_subnet.private-us-east-1a.id]
  
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "eks-network-lb"
  }
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.eks_cloudfront_distribution.domain_name
}
