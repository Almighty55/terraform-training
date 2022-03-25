output "sqlserver_privateIP" {
  # notice how this output is pulled in the root module
  value = aws_instance.sqlserver[*].private_ip
}