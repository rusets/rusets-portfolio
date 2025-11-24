############################################
# S3 Bucket - Terraform Remote State
# Purpose: Store terraform.tfstate for rusets-portfolio
############################################

resource "aws_s3_bucket" "state" {
  bucket = var.state_bucket_name

  tags = local.tags
}

############################################
# S3 Bucket Versioning
# Purpose: Keep history of terraform.tfstate revisions
############################################

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

############################################
# S3 Bucket Server-Side Encryption
# Purpose: Encrypt terraform state at rest
############################################

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

############################################
# DynamoDB Table - Terraform State Lock
# Purpose: Prevent concurrent terraform operations
############################################

resource "aws_dynamodb_table" "lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = local.tags
}
