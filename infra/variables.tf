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

############################################
# GitHub OIDC Configuration
# Purpose: Restrict IAM role to specific repo
############################################

variable "github_owner" {
  type        = string
  description = "GitHub owner (user or org) for OIDC trust"
  default     = "rusets"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name for OIDC trust"
  default     = "rusets-portfolio"
}
