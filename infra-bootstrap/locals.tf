############################################
# Local Values
# Purpose: Common tags for backend resources
############################################

locals {
  tags = {
    Project = var.project_name
    Owner   = "Ruslan AWS"
    Scope   = "terraform-backend"
  }
}
