output "web_sg_output" {
  value = aws_security_group.webserver_sg
  #value = ["${aws_security_group.webserver_sg}"]
}

output "sql_sg_output" {
  value = aws_security_group.sql_sg
}