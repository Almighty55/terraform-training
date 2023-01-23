resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "public_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.web-subnet[0].id #? route all NAT private traffic through one public subnet
}

#? answer to #1 self guided
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public_nat.id
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.application-subnet)
  subnet_id      = aws_subnet.application-subnet[count.index].id
  route_table_id = aws_route_table.private_rt.id
}