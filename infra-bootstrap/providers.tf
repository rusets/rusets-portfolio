############################################
# AWS Provider
# Purpose: Use a single region for backend resources
############################################

provider "aws" {
  region = var.aws_region
}


############################################
# Terraform settings
# Purpose: Required version and providers
############################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
