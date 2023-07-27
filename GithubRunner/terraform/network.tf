resource "aws_vpc" "gha" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "github-actions"
    user      = "github-actions"
    custodian = "terraform"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.gha.id

  tags = {
    Name = "igw"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "eip-nat"
  }
  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "nat-${aws_subnet.public[0].availability_zone}"
  }

  depends_on = [
    aws_internet_gateway.igw
  ]
}