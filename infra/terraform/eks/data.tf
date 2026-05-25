# Read outputs from the network/ stack.
# This is how stacks compose: each one exports outputs, dependents read them.
data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "paypulse-tfstate-658313dc"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}
