locals {
  csv_data = csvdecode(file("${path.module}/csv/web_server.csv"))
  sg_data = flatten([
    for sg_rule in local.csv_data : {
      description = sg_rule.Description
      type        = sg_rule.Type
      cidr_blocks = split(",", sg_rule.CIDR)
      protocol    = sg_rule.Protocol
      from_port   = sg_rule.From_port
      to_port     = sg_rule.To_port
      description = sg_rule.Description
    }
  ])
}

resource "aws_security_group" "webserver_sg" {
  name = "webserver_sg" 
  description = "webserver security group"
  vpc_id      = var.vpc_output.id
  tags = {
    Custodian = "managed-by-terraform"
  }
  lifecycle {
    # create a new sg in the event this one needs to be modified
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "webserver_sg" {
  count             = length(local.sg_data)
  security_group_id = aws_security_group.webserver_sg.id
  type              = local.sg_data[count.index].type
  cidr_blocks       = local.sg_data[count.index].cidr_blocks
  protocol          = local.sg_data[count.index].protocol
  from_port         = local.sg_data[count.index].from_port
  to_port           = local.sg_data[count.index].to_port
  description       = "${local.sg_data[count.index].description} - managed-by-terraform"

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
    description = "Allow traffic from TCP/80"
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