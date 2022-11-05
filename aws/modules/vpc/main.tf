# Create VPC in us-east-1
resource "aws_vpc" "dev_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Custodian = "managed-by-terraform"
    Name      = "dev-vpc"
  }
}

# Create IGW in us-east-1
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev_vpc.id
  tags = {
    Custodian = "managed-by-terraform"
    Name      = "dev-vpc igw"
  }
}

# Create route table in us-east-1
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.dev_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Custodian = "managed-by-terraform"
    Name      = "public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Create public subnet # 1 in us-east-1
resource "aws_subnet" "public_subnet" {
  availability_zone = "us-east-1a"
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.0.0.0/24"
  tags = {
    Custodian = "managed-by-terraform"
    Name      = "public subnet"
  }
}

# Create private subnet # 1 in us-east-1
resource "aws_subnet" "private_subnet" {
  availability_zone       = "us-east-1a"
  vpc_id                  = aws_vpc.dev_vpc.id
  map_public_ip_on_launch = false
  cidr_block              = "10.0.1.0/24"
  tags = {
    Custodian = "managed-by-terraform"
    Name      = "private subnet1"
  }
}

# Create private subnet # 1 in us-east-2
resource "aws_subnet" "private_subnet2" {
  availability_zone       = "us-east-1b"
  vpc_id                  = aws_vpc.dev_vpc.id
  map_public_ip_on_launch = false
  cidr_block              = "10.0.2.0/24"
  tags = {
    Custodian = "managed-by-terraform"
    Name      = "private subnet2"
  }
}