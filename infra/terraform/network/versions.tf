terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
  }

  # Same S3 bucket as bootstrap, but DIFFERENT key.
  # Each stack gets its own state file at its own key path.
  backend "s3" {
    bucket         = "paypulse-tfstate-658313dc"
    key            = "network/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "paypulse-tf-lock"
  }
}
