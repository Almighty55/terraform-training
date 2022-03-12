terraform {
  required_version = "~> 1.1.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.4.0"
    }
  }
  backend "s3" {
    bucket         = "alaraj-terraform-state"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    #! disabled for testing
    #dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}