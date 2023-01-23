#############################################
# INPUT VARIABLES
#############################################
variable "asg_names" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}

#############################################
# RESOURCES
#############################################
locals {
  asg_full = flatten([for name in var.asg_names : [for key, value in var.tags : {
    name = name,
    key  = key,
  value = value }]])
}

resource "aws_autoscaling_group_tag" "asg_tagger" {
  count                  = length(local.asg_full)
  autoscaling_group_name = local.asg_full[count.index].name
  tag {
    key                 = local.asg_full[count.index].key
    value               = local.asg_full[count.index].value
    propagate_at_launch = true
  }
}

#############################################
# OUTPUT
#############################################
output "asg_full" {
  value = local.asg_full
}