# Read network stack outputs to get VPC ID and private subnet IDs
data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "paypulse-tfstate-658313dc"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}
