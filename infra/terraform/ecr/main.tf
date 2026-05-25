# ============================================================================
# ECR REPOSITORIES
# One per service. Uses for_each so adding a new service is a one-line
# variable change.
# ============================================================================

resource "aws_ecr_repository" "this" {
  for_each = var.repositories

  name                 = each.key
  image_tag_mutability = each.value.image_tag_mutability
  force_delete         = true # dev only - allow destroy with images present

  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = each.key
  }
}

# ============================================================================
# LIFECYCLE POLICY
# - Keep the N most recent tagged images
# - Expire untagged images after X days
# Rules evaluate top to bottom; first match wins, so the "keep last N" rule
# comes BEFORE the "expire untagged" rule.
# ============================================================================

resource "aws_ecr_lifecycle_policy" "this" {
  for_each = var.repositories

  repository = aws_ecr_repository.this[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${each.value.max_image_count} tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPatternList = ["*"]
          countType     = "imageCountMoreThan"
          countNumber   = each.value.max_image_count
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Expire untagged images after ${each.value.untagged_expire_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = each.value.untagged_expire_days
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
