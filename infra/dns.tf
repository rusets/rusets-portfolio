############################################
# Route 53 Hosted Zone
# Purpose: Public DNS zone for rusets.com
############################################

resource "aws_route53_zone" "this" {
  name = var.domain_name

  tags = local.tags
}

############################################
# ACM Certificate Validation Records
# Purpose: DNS validation for TLS certificate
############################################

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.site.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.this.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 300

  records = [
    each.value.record,
  ]
}

############################################
# ACM Certificate Validation Resource
# Purpose: Complete validation after DNS records exist
############################################

resource "aws_acm_certificate_validation" "site" {
  provider = aws.us_east_1

  certificate_arn = aws_acm_certificate.site.arn
  validation_record_fqdns = [
    for record in aws_route53_record.cert_validation :
    record.fqdn
  ]
}

############################################
# Route 53 Alias Record for CloudFront (A and AAAA)
# Purpose: Point rusets.com to CloudFront distribution
############################################

resource "aws_route53_record" "root_a" {
  zone_id = aws_route53_zone.this.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "root_aaaa" {
  zone_id = aws_route53_zone.this.zone_id
  name    = var.domain_name
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}
