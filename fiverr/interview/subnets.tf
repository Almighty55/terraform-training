# Create Web Public Subnet
resource "aws_subnet" "web-subnet" {
  count                   = length(var.public_cidr_block)
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = element(sort(var.public_cidr_block), count.index)
  availability_zone       = element(sort(var.aws_availability_zones), count.index)
  map_public_ip_on_launch = true
}

resource "aws_subnet" "application-subnet" {
  count                   = length(var.private_cidr_block)
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = element(sort(var.private_cidr_block), count.index)
  availability_zone       = element(sort(var.aws_availability_zones), count.index)
  map_public_ip_on_launch = true
}