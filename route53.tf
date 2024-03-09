# AWS Route53 zone data source with the domain name and private zone set to false
data "aws_route53_zone" "zone" {
  name    = var.domain-name
  
}

# AWS Route53 record resource for certificate validation with dynamic for each loop and properties for name, records, type, zone id, and ttl

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options :
    dvo.domain_name => {
      name    = dvo.resource_record_name
      records = [dvo.resource_record_value]
      type    = dvo.resource_record_type
    }
  }

  zone_id = data.aws_route53_zone.zone.zone_id

  dynamic "record" {
    for_each = each.value
    content {
      name    = record.value.name
      records = record.value.records
      type    = record.value.type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = each.value.records
  type            = each.value.type
}

# AWS Route53 record resource for the "www" subdomain. The record uses an "A" type record and an alias to the AWS CloudFront distribution with the specified domain name and hosted zone ID. The target health evaluation is set to false.
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "www.${var.domain-name}"
  type    = "A"

  alias {
    name                       = aws_cloudfront_distribution.eks_cloudfront_distribution.domain_name
    zone_id                    = aws_cloudfront_distribution.eks_cloudfront_distribution.hosted_zone_id
    evaluate_target_health     = false
  }
}

# AWS Route53 record resource for the apex domain (root domain) with an "A" type record. The record uses an alias to the AWS CloudFront distribution with the specified domain name and hosted zone ID. The target health evaluation is set to false.
resource "aws_route53_record" "apex" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.domain-name
  type    = "A"

  alias {
    name                       = aws_cloudfront_distribution.eks_cloudfront_distribution.domain_name
    zone_id                    = aws_cloudfront_distribution.eks_cloudfront_distribution.hosted_zone_id
    evaluate_target_health     = false
  }
}
