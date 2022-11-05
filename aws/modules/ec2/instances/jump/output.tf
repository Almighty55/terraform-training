output "jump_publicIP" {
  value = aws_instance.jump[*].public_ip
}

output "jump_pwd_decrypted" {
  value = [
    for p in aws_instance.jump : rsadecrypt(p.password_data, file("${path.root}/keys/id_rsa"))
  ]
}