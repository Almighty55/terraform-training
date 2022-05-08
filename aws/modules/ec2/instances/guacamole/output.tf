output "guac_publicIP" {
  # notice how this output is pulled in the root module
  value = aws_instance.guac[*].public_ip
}