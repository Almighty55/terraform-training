output "web_sg_output" {
  value = aws_security_group.web_srv_sg
  #value = ["${aws_security_group.webserver_sg}"]
}

output "sql_sg_output" {
  value = aws_security_group.sql_srv_sg
}