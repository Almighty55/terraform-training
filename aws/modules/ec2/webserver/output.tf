output "webserver_publicIP" {
  # notice how this output is pulled in the root module
  value = aws_instance.webserver[*].public_ip
}