############################################
# S3 Bucket — Terraform remote state
# Purpose: Store Terraform state for portfolio infra
############################################
#tfsec:ignore:aws-s3-enable-bucket-logging
#tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "state" {
  bucket = var.state_bucket_name

  tags = local.tags
}

############################################
# S3 Bucket Encryption — remote state
# Purpose: Encrypt state files at rest (SSE-S3)
############################################
#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

############################################
# S3 Bucket Public Access Block — remote state
# Purpose: Block any public ACLs / policies
############################################
resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

############################################
# DynamoDB Table — Terraform state locks
# Purpose: Manage concurrent Terraform operations
############################################
#tfsec:ignore:aws-dynamodb-enable-recovery
#tfsec:ignore:aws-dynamodb-table-customer-key
resource "aws_dynamodb_table" "lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }
}
