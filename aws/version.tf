terraform {
  # specify terraform version
  required_version = "~> 1.3.3"
  # declare provider and settings
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
  # backend configs for managing state file
  backend "s3" {
    bucket = "alaraj-terraform-state"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-1"
    #! disabled for testing
    #dynamodb_table = "terraform-state-locking"
    encrypt = true
  }
}

# Configure the AWS Provider
provider "aws" {
  default_tags {
    tags = {
      Custodian = "managed-by-terraform"
    }
  }
}