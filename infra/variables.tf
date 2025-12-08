############################################
# Core Configuration Variables
# Purpose: Project name, region, domain
############################################

variable "project_name" {
  type        = string
  description = "Project name prefix for resource naming and tagging"
  default     = "rusets-portfolio"
}

variable "aws_region" {
  type        = string
  description = "Primary AWS region for the stack"
  default     = "us-east-1"
}

variable "domain_name" {
  type        = string
  description = "Root domain name for the portfolio site"
  default     = "rusets.com"
}


