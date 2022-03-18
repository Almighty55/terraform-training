# Create VPC in us-east-1
resource "aws_vpc" "tf_test_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Custodian = "managed-by-terraform"
    Name      = "tf-test-vpc"
  }
}

# Create IGW in us-east-1
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.tf_test_vpc.id
  tags = {
    Custodian = "managed-by-terraform"
  }
}

# Get main route table to modify
data "aws_route_table" "main_route_table" {
  filter {
    name   = "association.main"
    values = ["true"]
  }
  filter {
    name   = "vpc-id"
    values = [aws_vpc.tf_test_vpc.id]
  }
}

# Create route table in us-east-1
resource "aws_default_route_table" "internet_route" {
  default_route_table_id = data.aws_route_table.main_route_table.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Custodian = "managed-by-terraform"
    Name      = "WebServer-RouteTable"
  }
}

# Get all available AZ's in VPC for master region
data "aws_availability_zones" "azs" {
  state = "available"
}

# Create subnet # 1 in us-east-1
resource "aws_subnet" "subnet" {
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.tf_test_vpc.id
  cidr_block        = "10.0.1.0/24"
  tags = {
    Custodian = "managed-by-terraform"
  }
}