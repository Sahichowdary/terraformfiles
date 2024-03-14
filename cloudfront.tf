
# Create a security group for CloudFront
resource "aws_security_group" "cloudfront_sg" {
  name        = "cloudfront-sg"
  description = "Security group for CloudFront"
  vpc_id      = aws_vpc.private_vpc.id  # Specify the VPC ID where CloudFront will be deployed

  ingress {
    from_port   = 80
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allowing traffic from anywhere, you may restrict it as per your requirements
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloudfront-sg"
  }
}


# Update CloudFront distribution to point to NLB
resource "aws_cloudfront_distribution" "eks_cloudfront_distribution" {
  depends_on = [aws_lb.nlb] 
  origin {
    domain_name = aws_elb.elbfood.dns_name
    origin_id   = aws_elb.elbfood.arn

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
    target_origin_id = "aws_lb.nlb.arn"

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


resource "aws_security_group_rule" "cloudfront_to_nlb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.nlb_sg.id
  source_security_group_id = aws_security_group.cloudfront_sg.id
}


output "cloudfront_url" {
  value = aws_cloudfront_distribution.eks_cloudfront_distribution.domain_name
}
