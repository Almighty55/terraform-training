output "vpc_id" {
    # this sends the output to the root module then there we declare it in the webserver module
    value = aws_vpc.alaraj_vpc
}