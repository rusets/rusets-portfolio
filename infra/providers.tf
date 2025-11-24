############################################
# AWS Providers
# Purpose: Main region provider + us-east-1 for ACM
############################################

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

############################################
# Caller Identity and Region Data
# Purpose: Use account ID and region in locals and names
############################################

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
