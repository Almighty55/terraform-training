output "sqlserver_privateIP" {
  # notice how this output is pulled in the root module
  value = aws_instance.sqlserver[*].private_ip
}

output "sqlserver_pwd_decrypted" {
  value = [
    for p in aws_instance.sqlserver : rsadecrypt(p.password_data, file("${path.root}/keys/id_rsa"))
  ]
}