
resource "aws_acm_certificate" "cert" {
domain_name = "saskenpoc.com"
  subject_alternative_names = [
       "*.saskenpoc.com",    
       "api.saskenpoc.com",
       "poc.saskenpoc.com"
           ]
 
  validation_method = "DNS"
 
  lifecycle {
    create_before_destroy = true
  }
}

# ACM certificate validation resource using the certificate ARN and a list of validation record FQDNS
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn   = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for validation_option in aws_acm_certificate.cert.domain_validation_options :
    validation_option.resource_record_name => validation_option
  }

  zone_id = data.aws_route53_zone.zone.zone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  records = [each.value.resource_record_value]
  ttl     = 60
}

 
