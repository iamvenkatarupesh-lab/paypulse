variable "aws_region" {
  description = "AWS region for ECR repositories"
  type        = string
  default     = "us-east-1"
}

variable "repositories" {
  description = "Map of ECR repositories to create. Key = repo name, value = config."
  type = map(object({
    image_tag_mutability = string
    scan_on_push         = bool
    max_image_count      = number
    untagged_expire_days = number
  }))
  default = {
    "paypulse/frontend" = {
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
      max_image_count      = 20
      untagged_expire_days = 7
    }
    "paypulse/backend" = {
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
      max_image_count      = 20
      untagged_expire_days = 7
    }
  }
}
