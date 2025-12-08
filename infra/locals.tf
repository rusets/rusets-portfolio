############################################
# Global locals
# Purpose: Common names and tags
############################################

locals {
  project_name        = "rusets-portfolio"
  site_bucket_name    = "${local.project_name}-site-${data.aws_caller_identity.current.account_id}"
  cf_logs_bucket_name = "${local.project_name}-cf-logs-${data.aws_caller_identity.current.account_id}"

  tags = {
    Project = local.project_name
    Owner   = "Ruslan AWS"
  }
}
