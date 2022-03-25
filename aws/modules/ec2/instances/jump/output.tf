output "jumpserver_publicIP" {
  # notice how this output is pulled in the root module
  value = aws_instance.jumpserver[*].public_ip
}