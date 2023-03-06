terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  # backend configs for managing state file - bucket is auto created in GHA pipeline
  backend "s3" {
    bucket = "123456cloudbyte1324561"
    key    = "tfstate/gha/production/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

# Configure AWS provider
provider "aws" {
  region = "us-east-1"
}