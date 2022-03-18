output "web_sg_output" {
  value = aws_security_group.web_sg
}

output "sql_sg_output" {
  value = aws_security_group.sql_sg
}