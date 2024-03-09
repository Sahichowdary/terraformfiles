resource "aws_wafv2_web_acl" "pocawswaf" {
  name        = "poc-web-acl"
  description = "poc for foodfinder WAF Web ACL"
  scope       = "CLOUDFRONT"

  default_action {
    block {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "poc-web-acl-metrics"
    sampled_requests_enabled   = true
  }

  # Rule for blocking requests based on the referrer header
  rule {
    name     = "block-referrer"
    priority = 1

    action {
      block {}
    }

    statement {
      regex_pattern_set_reference_statement {
        arn = aws_wafv2_regex_pattern_set.poc.arn
        field_to_match {
          single_header {
            name = "referer"
          }
        }
        text_transformation {
          priority = 1
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockReferrerRule"
      sampled_requests_enabled   = true
    }
  }
}

resource "aws_wafv2_regex_pattern_set" "poc" {
  name        = "poc-regex-pattern-set"
  description = "poc Regex Pattern Set"
  scope       = "CLOUDFRONT"

  regular_expression {
    regex_string = "saskenpoc.com"
  }
}

resource "aws_wafv2_web_acl_association" "pocwafaclcnd" {
  resource_arn = aws_cloudfront_distribution.eks_cloudfront_distribution.arn
  web_acl_arn  = aws_wafv2_web_acl.pocawswaf.arn
  depends_on = [aws_cloudfront_distribution.eks_cloudfront_distribution, aws_wafv2_web_acl.pocawswaf.arn]
}
