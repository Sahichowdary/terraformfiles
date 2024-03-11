
# Create CloudFront distribution
resource "aws_cloudfront_distribution" "eks_cloudfront_distribution" {
  origin {
    domain_name = aws_lb.existing_classic_load_balancer.domain_name
    origin_id   = "a173699949b2a4516bfebfa05d007725"

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


# Define your Classic Load Balancer
# Define data source to retrieve information about the existing Classic Load Balancer
data "aws_elb" "existing_classic_load_balancer" {
  name = "a173699949b2a4516bfebfa05d007725"  # Replace with the name of your existing CLB
}


# Create an AWS Global Accelerator
resource "aws_globalaccelerator_accelerator" "global_accelerator" {
  name               = "my-global-accelerator"
  enabled            = true
}

