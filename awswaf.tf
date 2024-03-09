resource "aws_wafv2_web_acl" "pocawswaf" {
  name        = "poc-web-acl"
  description = "poc for foodfinder WAF Web ACL"
  scope       = "CLOUDFRONT"

  default_action {
    block {}
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
        field_to_match {
          single_header {
            name = "referer"
          }
        }
        text_transformations {
          priority = 1
          type     = "NONE"
        }
        regex_pattern_set_id = aws_wafv2_regex_pattern_set.example.id
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockReferrerRule"
      sampled_requests_enabled   = true
    }
  }
}

resource "aws_wafv2_regex_pattern_set" "example" {
  name        = "example-regex-pattern-set"
  description = "Example Regex Pattern Set"

  regular_expression {
    regex_string = "example.com"
  }
}

resource "aws_wafv2_web_acl_association" "example" {
  resource_arn = aws_cloudfront_distribution.eks_cloudfront_distribution.arn
  web_acl_arn  = aws_wafv2_web_acl.example.arn
}
