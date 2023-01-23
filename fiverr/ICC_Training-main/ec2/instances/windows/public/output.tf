output "windows_public_ip" {
  value = aws_instance.windows_pub[*].public_ip
}

output "password" {
  value = local.password
  sensitive = true  
}