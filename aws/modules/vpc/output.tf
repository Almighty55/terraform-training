output "vpc_output" { # whatever name is used here is the identifier in the root main.tf
    # this sends the output to the root module then there we declare it in the webserver module
    value = aws_vpc.tf_test_vpc
}