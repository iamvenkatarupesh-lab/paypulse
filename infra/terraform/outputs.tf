output "tf_state_bucket_name" {
  description = "Name of the S3 bucket storing Terraform state"
  value       = aws_s3_bucket.tf_state.id
}

output "tf_state_bucket_region" {
  description = "AWS region of the state bucket"
  value       = var.aws_region
}

output "tf_state_bucket_arn" {
  description = "ARN of the state bucket"
  value       = aws_s3_bucket.tf_state.arn
}
