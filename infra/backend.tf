############################################
# Terraform Backend Configuration
# Purpose: Remote state in existing S3 + DynamoDB
############################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {
    bucket         = "tf-state-rusets-portfolio"
    key            = "rusets-portfolio/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-locks-rusets-portfolio"
    encrypt        = true
  }
}
