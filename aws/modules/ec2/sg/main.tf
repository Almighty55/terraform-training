# Create SG for allowing TCP/80 & TCP/22
resource "aws_security_group" "web_sg" {
  name        = "webserver-sg"
  description = "Allow TCP/80 & TCP/22"
  vpc_id      = var.vpc_output.id
  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow traffic from TCP/80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Custodian = "managed-by-terraform"
  }
  lifecycle {
    # create a new sg in the event this one needs to be modified
    create_before_destroy = true
  }
}

resource "aws_security_group" "sql_sg" {
  name        = "sql-sg"
  description = "Allow TCP/80 & TCP/22"
  vpc_id      = var.vpc_output.id
  ingress {
    description = "Allow RDP traffic"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow traffic from TCP/80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow RDP traffic"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Custodian = "managed-by-terraform"
  }
  lifecycle {
    # create a new sg in the event this one needs to be modified
    create_before_destroy = true
  }
}