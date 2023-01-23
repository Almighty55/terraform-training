#############################################
# VARIABLES
#############################################
variable "tags" {
  type = map(string)
  default = {
    product = "test"
    name    = "email"
    user    = "joe smith"
  }
}

variable "asg_names" {
  type = list(string)
  default = [
    "asg_name_1",
    "asg_name_2",
    "asg_name_3"
  ]
}

#############################################
# MODULE CALLS
#############################################
module "asg_tagger" {
  source    = "./asg_tagger/"
  asg_names = var.asg_names
  tags      = var.tags
}

#############################################
# OUTPUT
#############################################
output "asg_full" {
  value = module.asg_tagger.asg_full
}