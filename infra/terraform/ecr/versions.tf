terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }

  backend "s3" {
    bucket         = "paypulse-tfstate-658313dc"
    key            = "ecr/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "paypulse-tf-lock"
    encrypt        = true
  }
}
