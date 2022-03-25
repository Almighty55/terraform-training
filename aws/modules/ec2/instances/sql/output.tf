output "sqlserver_publicIP" {
  # notice how this output is pulled in the root module
  value = aws_instance.sqlserver[*].public_ip
}