############################################
# AWS Provider
# Purpose: Use a single region for backend resources
############################################

provider "aws" {
  region = var.aws_region
}

############################################
# Caller Identity
# Purpose: Use account ID in tags if needed
############################################

data "aws_caller_identity" "current" {}
