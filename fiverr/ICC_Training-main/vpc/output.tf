output "vpc_output" { # whatever name is used here is the identifier in the root main.tf
  # this sends the output to the root module then there we declare it in the webserver module
  value = aws_vpc.dev_vpc
}

output "igw" {
  value = aws_internet_gateway.igw
}

output "public_subnet_output" {
  value = aws_subnet.public_subnet
}

output "private_subnet_output" {
  value = aws_subnet.private_subnet
}

output "private_subnet2_output" {
  value = aws_subnet.private_subnet2
}