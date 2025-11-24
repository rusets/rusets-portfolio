############################################
# Local Values
# Purpose: Common tags and derived names
############################################

locals {
  tags = {
    Project = var.project_name
    Owner   = "Ruslan AWS"
  }

  site_bucket_name = "${var.project_name}-site-${data.aws_caller_identity.current.account_id}"
}
