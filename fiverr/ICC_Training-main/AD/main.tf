#* AWS Directory Service Microsoft AD
resource "aws_directory_service_directory" "aws_managed_ad" {
  name        = "goongoblin.tk"                           
  description = "goongoblin.tk Managed Directory Service" 
  password    = "Test@123"                                
  size        = "Small"                                   
  edition     = "Standard"
  type        = "MicrosoftAD"
  vpc_settings {
    vpc_id = var.vpc_output.id
    subnet_ids = [var.private_subnet_output.id, var.private_subnet2_output.id]
  }
  tags = {
    Name      = "goongoblin-managed-ad"
    Custodian = "managed-by-terraform"
  }
}

# # # !Testing
# provider "ad" {
#   winrm_hostname         = "54.205.46.67"
#   winrm_username         = "Admin" # Default username
#   winrm_password         = "Test@123"
#   krb_realm              = "10.0.1.161"
#   krb_conf               = "${path.module}/krb5.conf"
#   krb_spn                = "EC2AMAZ-GMCBSS8"
#   winrm_port             = 5986
#   winrm_proto            = "https"
#   winrm_pass_credentials = true
#   winrm_insecure         = true
# }

# #* Active Directory OU creation
# resource "ad_ou" "trainee_ou" {
#   name        = "trainees"                   
#   path        = "OU=goongoblin,DC=goongoblin,DC=tk" 
#   description = "OU for testusers"            
#   protected   = false                         
# }



# resource "ad_ou" "trainees_ou" {
#   name        = "trainees"
#   path        = "OU=iavirtualtraini,OU=test,DC=goongoblin,DC=tk" #TODO: change for prod
#   description = "OU for trainees"                                 #TODO: change for prod
#   protected   = false                                             #TODO: change for prod
#   depends_on = [
#     ad_ou.iavirtualtraini_ou
#   ]
# }


# * Active Directory Group Creation
# locals {
#   groups_csv = csvdecode(file("${path.module}/csv/groups.csv"))
#   groups_csv_data = flatten([
#     for group in local.groups_csv : {
#       name             = group.name
#       sam_account_name = group.sam_account_name
#       # container        = group.container  #! leverage csv if below OU doesn't work
#     }
#   ])

# }
# resource "ad_group" "groups" {
#   count            = length(local.groups_csv_data)
#   name             = local.groups_csv_data[count.index].name
#   sam_account_name = local.groups_csv_data[count.index].sam_account_name
#   scope            = "Security"
#   category         = "Global"
#   container        = ad_ou.ou.dn #! leverage csv if this doesn't work
# }


# #* Active Directory User Creation
# locals {
#   user_csv = csvdecode(file("${path.module}/csv/user.csv"))
#   user_csv_data = flatten([
#     for new_user in local.user_csv : {
#       first_name          = new_user.first_name
#       last_name           = new_user.last_name
#       class               = new_user.class
#       email_address       = new_user.email_address
#       description         = new_user.description
#       organizational_unit = new_user.organizational_unit
#       groups              = new_user.groups
#       enabled             = new_user.enabled
#     }
#   ])
# }
# resource "ad_user" "users" {
#   count            = length(local.user_csv_data)
#   display_name     = "${local.user_csv_data[count.index].first_name} ${local.user_csv_data[count.index].last_name}"
#   principal_name   = "${local.user_csv_data[count.index].first_name}${local.user_csv_data[count.index].last_name}"
#   sam_account_name = "${local.user_csv_data[count.index].first_name}${local.user_csv_data[count.index].last_name}"
#   department       = local.user_csv_data[count.index].class
#   description      = local.user_csv_data[count.index].description
#   email_address    = local.user_csv_data[count.index].email_address
#   given_name       = local.user_csv_data[count.index].first_name
#   surname          = local.user_csv_data[count.index].last_name
#   enabled          = tobool(local.user_csv_data[count.index].enabled)
#   depends_on = [
#     ad_ou.trainees_ou,
#     ad_group.groups
#   ]
# }

# TODO: Get this to loop through the groups of the csv
# resource "ad_group_membership" "group_membs" {
#   group_id      = ad_group.groups.id
#   group_members = [ad_group.g2.id, ad_user.u.id]

#   depends_on = [
#     ad_user.users,
#     ad_ou.trainees_ou,
#     ad_group.groups
#   ]
# }