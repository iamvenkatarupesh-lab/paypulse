output "repository_urls" {
  description = "Map of repository name to URL (use these for docker tag/push)"
  value = {
    for k, v in aws_ecr_repository.this : k => v.repository_url
  }
}

output "repository_arns" {
  description = "Map of repository name to ARN"
  value = {
    for k, v in aws_ecr_repository.this : k => v.arn
  }
}

output "registry_id" {
  description = "AWS account ID hosting these registries (same as your account)"
  value       = data.aws_caller_identity.current.account_id
}

output "docker_login_command" {
  description = "Run this to log Docker into your ECR registry (token valid 12h)"
  value       = "aws ecr get-login-password --region ${var.aws_region} --profile paypulse | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}
