############################################
# Core Variables
# Purpose: Control region and naming for state backend
############################################

variable "project_name" {
  type        = string
  description = "Project name for tagging and backend naming"
  default     = "rusets-portfolio"
}

variable "aws_region" {
  type        = string
  description = "AWS region for backend resources"
  default     = "us-east-1"
}

variable "state_bucket_name" {
  type        = string
  description = "S3 bucket name for Terraform remote state"
  default     = "tf-state-rusets-portfolio"
}

variable "lock_table_name" {
  type        = string
  description = "DynamoDB table name for Terraform state locking"
  default     = "tf-locks-rusets-portfolio"
}
