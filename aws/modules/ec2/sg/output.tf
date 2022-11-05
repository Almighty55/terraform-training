output "web_sg_output" {
  value = aws_security_group.web_srv_sg
}

output "guac_sg_output" {
  value = aws_security_group.guac_srv_sg
}

output "sql_sg_output" {
  value = aws_security_group.sql_srv_sg
}

output "jump_sg_output" {
  value = aws_security_group.jump_srv_sg
}