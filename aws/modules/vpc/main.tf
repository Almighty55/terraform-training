# Create VPC in us-east-1
resource "aws_vpc" "tf_test_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Custodian = "managed-by-terraform"
    Name = "tf-test-vpc"
  }
}