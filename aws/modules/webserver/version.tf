terraform {
  # specify the terraform version
  required_version = "~> 1.1.7"

  required_providers {
    # declare aws provider settings
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.4.0"
    }
  }
}