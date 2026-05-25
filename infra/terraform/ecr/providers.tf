provider "aws" {
  region  = var.aws_region
  profile = "paypulse"

  default_tags {
    tags = {
      Project     = "paypulse"
      Environment = "dev"
      ManagedBy   = "Terraform"
      Owner       = "Rupesh"
      Stack       = "ecr"
    }
  }
}
