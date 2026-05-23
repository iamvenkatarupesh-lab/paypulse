# Random suffix so the bucket name is globally unique
# S3 bucket names are a global namespace across all AWS accounts.
resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "tf_state" {
  bucket = "${var.project_name}-tfstate-${random_id.suffix.hex}"

  # Prevent accidental deletion of this critical bucket
  lifecycle {
    prevent_destroy = true
  }
}

# Versioning: every state write creates a new version.
# If state gets corrupted, you can roll back to a previous version.
resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encryption at rest with AWS-managed keys (AES-256).
# Terraform state contains secrets — DB passwords, API keys.
# Never store unencrypted.
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block ALL public access. State files must never be public.
resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
