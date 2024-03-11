# Define your Classic Load Balancer
data "aws_elb" "my_classic_load_balancer" {
  name               = "a173699949b2a4516bfebfa05d007725"
  availability_zones = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]  # Specify the availability zones for the load balancer
  internal           = false                         # Set to true if the load balancer is internal
  security_groups    = ["sg-12345678"]               # Specify the security groups for the load balancer
  listeners {
    instance_port     = 80                            # Port on the instances
    instance_protocol = "HTTP"                        # Protocol to use for routing traffic to the instances
    lb_port           = 80                            # Port on the load balancer
    lb_protocol       = "HTTP"                        # Protocol to use for routing traffic from clients to the load balancer
  }
  health_check {
    target              = "HTTP:80/"                  # Target for the health check (e.g., HTTP:80/)
    interval            = 30                           # Interval (in seconds) between health checks
    timeout             = 5                            # Timeout (in seconds) for each health check
    healthy_threshold   = 2                            # Number of consecutive successful health checks required to consider an instance healthy
    unhealthy_threshold = 2                            # Number of consecutive failed health checks required to consider an instance unhealthy
  }
  tags = {
    Name = "a173699949b2a4516bfebfa05d007725"
  }
}

# Create CloudFront distribution
resource "aws_cloudfront_distribution" "eks_cloudfront_distribution" {
  origin {
    domain_name = aws_lb.my_classic_load_balancer.domain_name
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
  listener_arn      = "aws_globalaccelerator_listener.listener.arn"
  endpoint_group_region = "ap-southeast-2"  # Specify the region where the NLB is deployed
  endpoint_configuration {
    endpoint_id = aws_lb.eks_network_load_balancer.name
  }
}

# Create a listener for the Global Accelerator
resource "aws_globalaccelerator_listener" "listener" {
  accelerator_arn = "aws_globalaccelerator_accelerator.global_accelerator.arn"
  port_range {
    from_port = 80
    to_port   = 80
  }
  protocol = "TCP"
}
