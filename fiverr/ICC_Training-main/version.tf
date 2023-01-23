terraform {
  required_version = "~> 1.3.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  
  # backend configs for managing state file
  # backend "s3" {
  #   bucket = "ICC-training-terraform-state"
  #   key    = "global/s3/terraform.tfstate"
  #   region = "us-east-1"
  #   encrypt = true
  # }
}

#* commands to create backend bucket if it doesn't exist
# aws s3api create-bucket --bucket "ICC-training-terraform-state""  --region "us-east-1" --create-bucket-configuration LocationConstraint="us-east-1"
# aws s3api put-public-access-block --bucket "ICC-training-terraform-state""  --region "us-east-1" --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
# aws s3api put-bucket-versioning --bucket "ICC-training-terraform-state"" --versioning-configuration MFADelete=Disabled,Status=Enabled