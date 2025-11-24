############################################
# Key Outputs
# Purpose: Expose values for GitHub Actions and manual checks
############################################

output "site_bucket_name" {
  description = "Name of the S3 bucket storing static site content"
  value       = aws_s3_bucket.site.id
}

output "cloudfront_domain_name" {
  description = "Default CloudFront domain name"
  value       = aws_cloudfront_distribution.site.domain_name
}

output "route53_zone_name_servers" {
  description = "Name servers for the Route 53 hosted zone (add to registrar)"
  value       = aws_route53_zone.this.name_servers
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions OIDC"
  value       = aws_iam_role.github_actions.arn
}
