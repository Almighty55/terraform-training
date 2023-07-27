terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.00"
    }
  }

  backend "s3" {
    bucket         = "cloudbytetester1234"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
    key            = "gha/production/terraform.tfstate"
    region         = "us-east-1"
  }
}




# Configure AWS provider
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      custodian = "terraform-gha"
    }
  }
}


#? setup backend commands
# # Create S3 bucket
# aws s3api create-bucket `
#     --bucket cloudbytetester1234 `
#     --region us-east-1

# # Enable default encryption for the bucket
# aws s3api put-bucket-encryption `
#     --bucket cloudbytetester1234 `
#     --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'

# # Enable versioning for the bucket
# aws s3api put-bucket-versioning `
#     --bucket cloudbytetester1234 `
#     --versioning-configuration Status=Enabled

# # Create DynamoDB table for Terraform locking
# aws dynamodb create-table `
#     --table-name terraform-lock-table `
#     --attribute-definitions AttributeName=LockID,AttributeType=S `
#     --key-schema AttributeName=LockID,KeyType=HASH `
#     --billing-mode PAY_PER_REQUEST