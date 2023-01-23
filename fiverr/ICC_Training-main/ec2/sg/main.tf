/* For each new security group there needs to be a csv with the data placed in the csv folder.
Then in this main.tf you need to copy locals, aws_security_group, and aws_security_group_rule.
Swap out the appropriate variables. Then in output.tf add the output of the aws_security_group
so that it can be leveraged in the root main.tf.
*/

#* Public Windows SG
locals {
  windows_pub_csv = csvdecode(file("${path.module}/csv/windows_public.csv"))
  windows_pub_data = flatten([
    for sg_rule in local.windows_pub_csv : {
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
resource "aws_security_group" "windows_pub_sg" {
  name        = "windows-pub"
  description = "windows pub security group"
  vpc_id      = var.vpc_output.id
  tags = {
    Custodian = "managed-by-terraform"
  }
  lifecycle {
  # create a new sg in the event this one needs to be modified
  create_before_destroy = true
}
}
resource "aws_security_group_rule" "windows_pub_sgr" {
  count             = length(local.windows_pub_data)
  security_group_id = aws_security_group.windows_pub_sg.id
  type              = local.windows_pub_data[count.index].type
  cidr_blocks       = local.windows_pub_data[count.index].cidr_blocks
  protocol          = local.windows_pub_data[count.index].protocol
  from_port         = local.windows_pub_data[count.index].from_port
  to_port           = local.windows_pub_data[count.index].to_port
  description       = "${local.windows_pub_data[count.index].description} - managed-by-terraform"
  lifecycle {
  # create a new sg in the event this one needs to be modified
  create_before_destroy = true
}
}