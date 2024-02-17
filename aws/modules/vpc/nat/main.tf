resource "aws_eip" "nat_eip" {
  domain           = "vpc"
  depends_on = [var.igw_output]
  tags = {
    Custodian = "managed-by-terraform"
    Name      = "nat gateway eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = var.public_subnet_output.id
  tags = {
    Custodian = "managed-by-terraform"
    Name      = "dev-vpc nat gateway"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = var.vpc_output.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Custodian = "managed-by-terraform"
    Name      = "private-route-table"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = var.private_subnet_output.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = var.private_subnet2_output.id
  route_table_id = aws_route_table.private_rt.id
}