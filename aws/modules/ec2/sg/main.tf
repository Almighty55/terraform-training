/* For each new security group there needs to be a csv with the data placed in the csv folder.
Then in this main.tf you need to copy locals, aws_security_group, and aws_security_group_rule.
Swap out the appropriate variables. Then in output.tf add the output of the aws_security_group
so that it can be leveraged in the root main.tf.
*/

locals {
  web_srv_csv = csvdecode(file("${path.module}/csv/web_server.csv"))
  web_srv_data = flatten([
    for sg_rule in local.web_srv_csv : {
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
resource "aws_security_group" "web_srv_sg" {
  name        = "web-server"
  description = "web server security group"
  vpc_id      = var.vpc_output.id
  tags = {
    Custodian = "managed-by-terraform"
  }
  lifecycle {
    # create a new sg in the event this one needs to be modified
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "web_srv_sgr" {
  count             = length(local.web_srv_data)
  security_group_id = aws_security_group.web_srv_sg.id
  type              = local.web_srv_data[count.index].type
  cidr_blocks       = local.web_srv_data[count.index].cidr_blocks
  protocol          = local.web_srv_data[count.index].protocol
  from_port         = local.web_srv_data[count.index].from_port
  to_port           = local.web_srv_data[count.index].to_port
  description       = "${local.web_srv_data[count.index].description} - managed-by-terraform"

  lifecycle {
    # create a new sgr in the event this one needs to be modified
    create_before_destroy = true
  }
}


locals {
  guac_srv_csv = csvdecode(file("${path.module}/csv/guac_server.csv"))
  guac_srv_data = flatten([
    for sg_rule in local.guac_srv_csv : {
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
resource "aws_security_group" "guac_srv_sg" {
  name        = "guac-server"
  description = "guac server security group"
  vpc_id      = var.vpc_output.id
  tags = {
    Custodian = "managed-by-terraform"
  }
  lifecycle {
    # create a new sg in the event this one needs to be modified
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "guac_srv_sgr" {
  count             = length(local.guac_srv_data)
  security_group_id = aws_security_group.guac_srv_sg.id
  type              = local.guac_srv_data[count.index].type
  cidr_blocks       = local.guac_srv_data[count.index].cidr_blocks
  protocol          = local.guac_srv_data[count.index].protocol
  from_port         = local.guac_srv_data[count.index].from_port
  to_port           = local.guac_srv_data[count.index].to_port
  description       = "${local.guac_srv_data[count.index].description} - managed-by-terraform"

  lifecycle {
    # create a new sgr in the event this one needs to be modified
    create_before_destroy = true
  }
}


locals {
  sql_srv_csv = csvdecode(file("${path.module}/csv/sql_server.csv"))
  sql_srv_data = flatten([
    for sg_rule in local.sql_srv_csv : {
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
resource "aws_security_group" "sql_srv_sg" {
  name        = "sql-server"
  description = "sql server security group"
  vpc_id      = var.vpc_output.id
  tags = {
    Custodian = "managed-by-terraform"
  }
  lifecycle {
    # create a new sg in the event this one needs to be modified
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "sql_srv_sgr" {
  count             = length(local.sql_srv_data)
  security_group_id = aws_security_group.sql_srv_sg.id
  type              = local.sql_srv_data[count.index].type
  cidr_blocks       = local.sql_srv_data[count.index].cidr_blocks
  protocol          = local.sql_srv_data[count.index].protocol
  from_port         = local.sql_srv_data[count.index].from_port
  to_port           = local.sql_srv_data[count.index].to_port
  description       = "${local.sql_srv_data[count.index].description} - managed-by-terraform"

  lifecycle {
    # create a new sgr in the event this one needs to be modified
    create_before_destroy = true
  }
}


locals {
  jump_srv_csv = csvdecode(file("${path.module}/csv/jump_server.csv"))
  jump_srv_data = flatten([
    for sg_rule in local.jump_srv_csv : {
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
resource "aws_security_group" "jump_srv_sg" {
  name        = "jump-server"
  description = "jump server security group"
  vpc_id      = var.vpc_output.id
  tags = {
    Custodian = "managed-by-terraform"
  }
  lifecycle {
    # create a new sg in the event this one needs to be modified
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "jump_srv_sgr" {
  count             = length(local.jump_srv_data)
  security_group_id = aws_security_group.jump_srv_sg.id
  type              = local.jump_srv_data[count.index].type
  cidr_blocks       = local.jump_srv_data[count.index].cidr_blocks
  protocol          = local.jump_srv_data[count.index].protocol
  from_port         = local.jump_srv_data[count.index].from_port
  to_port           = local.jump_srv_data[count.index].to_port
  description       = "${local.jump_srv_data[count.index].description} - managed-by-terraform"

  lifecycle {
    # create a new sgr in the event this one needs to be modified
    create_before_destroy = true
  }
}