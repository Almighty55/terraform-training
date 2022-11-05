#* AWS Directory Service Microsoft AD
resource "aws_directory_service_directory" "aws_managed_ad" {
  count       = 0
  name        = "testAD.local"
  description = "testAD Managed Directory Service"
  password    = "Sup3rS3cr3tP@ssw0rd"
  edition     = "Standard"
  type        = "MicrosoftAD"
  vpc_settings {
    vpc_id     = var.vpc_output.id
    subnet_ids = [var.private_subnet_output.id, var.private_subnet2_output.id]
  }
  tags = {
    Name      = "testAD-managed-ad"
    Custodian = "managed-by-terraform"
  }
}

# #TODO: Get this to connect automatically
# #* Active Directory Connection
# provider "ad" {
#   winrm_hostname = "testAD.local"
#   winrm_username = "Admin" # Default username
#   winrm_password = aws_directory_service_directory.aws_managed_ad.password
#   # krb_realm              = "testAD.local"
#   # krb_conf               = "${path.module}/krb5.conf"
#   # krb_spn                = "winserver1"
#   # winrm_port             = 5986
#   # winrm_proto            = "https"
#   # winrm_pass_credentials = true
# }

# #* Active Directory User Creation
# locals {
#   user_csv = csvdecode(file("${path.module}/csv/user.csv"))
#   user_csv_data = flatten([
#     for new_user in local.user_csv : {
#       principal_name = new_user.principal_name
#       samaccountname = new_user.samaccountname
#       container      = new_user.container
#     }
#   ])
# }
# # all user attributes
# resource "ad_user" "u" {
#   count                     = length(local.user_csv_data)
#   principal_name            = local.user_csv_data[count.index].principal_name
#   sam_account_name          = local.user_csv_data[count.index].samaccountname
#   display_name              = "Terraform Test User"
#   container                 = local.user_csv_data[count.index].container
#   initial_password          = "Password"
#   city                      = "City"
#   company                   = "Company"
#   country                   = "us"
#   department                = "Department"
#   description               = "Description"
#   division                  = "Division"
#   email_address             = "some@email.com"
#   employee_id               = "id"
#   employee_number           = "number"
#   fax                       = "Fax"
#   given_name                = "GivenName"
#   home_directory            = "HomeDirectory"
#   home_drive                = "HomeDrive"
#   home_phone                = "HomePhone"
#   home_page                 = "HomePage"
#   initials                  = "Initia"
#   mobile_phone              = "MobilePhone"
#   office                    = "Office"
#   office_phone              = "OfficePhone"
#   organization              = "Organization"
#   other_name                = "OtherName"
#   po_box                    = "POBox"
#   postal_code               = "PostalCode"
#   state                     = "State"
#   street_address            = "StreetAddress"
#   surname                   = "Surname"
#   title                     = "Title"
#   smart_card_logon_required = false
#   trusted_for_delegation    = true
# }



#* Bind Domain


# resource "aws_ssm_document" "ad-join-domain" {
#   name          = "ad-join-domain"
#   document_type = "Command"
#   content = jsonencode(
#     {
#       "schemaVersion" = "2.2"
#       "description"   = "aws:domainJoin"
#       "mainSteps" = [
#         {
#           "action" = "aws:domainJoin",
#           "name"   = "domainJoin",
#           "inputs" = {
#             "directoryId" : aws_directory_service_directory.aws_managed_ad.id,
#             "directoryName" : aws_directory_service_directory.aws_managed_ad.name
#             "dnsIpAddresses" : sort(aws_directory_service_directory.aws_managed_ad.dns_ip_addresses)
#           }
#         }
#       ]
#     }
#   )
# }

# resource "aws_ssm_association" "windows_server" {
#   name = aws_ssm_document.ad-join-domain.name
#   targets {
#     key    = "InstanceIds"
#     values = ["i-0c0db5b1600841217"]
#   }
# }