# Create CloudFront distribution
resource "aws_cloudfront_distribution" "eks_cloudfront_distribution" {
  origin {
    domain_name = aws_route53_record.global_accelerator_alias.fqdn
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


# Create a Network Load Balancer (NLB) in the EKS region
resource "aws_lb" "eks_nlb" {
  name               = "eks-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = ["private-us-east-1a", "private-us-east-1b"]  # Specify your subnets in the EKS region
}

# Create an AWS Global Accelerator
resource "aws_globalaccelerator_accelerator" "global_accelerator" {
  name               = "my-global-accelerator"
  enabled            = true
}

# Create an endpoint group for the NLB
resource "aws_globalaccelerator_endpoint_group" "nlb_endpoint_group" {
  listener_arn      = aws_globalaccelerator_listener.listener.arn
  endpoint_group_region = "ap-southeast-2"  # Specify the region where the NLB is deployed
  endpoint_configurations {
    endpoint_id = a173699949b2a4516bfebfa05d007725-1712453856.ap-southeast-2.elb.amazonaws.com
  }
}

# Create a listener for the Global Accelerator
resource "aws_globalaccelerator_listener" "listener" {
  accelerator_arn = aws_globalaccelerator_accelerator.global_accelerator.arn
  port_range {
    from_port = 80
    to_port   = 80
  }
  protocol = "TCP"
}
