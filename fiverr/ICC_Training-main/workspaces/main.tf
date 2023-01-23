resource "aws_workspaces_directory" "workspaces-directory" {
  directory_id = var.aws_managed_ad_output.id
  subnet_ids   = [var.private_subnet_output.id, var.private_subnet2_output.id]
#   depends_on = [aws_iam_role.workspaces-default]
}

data "aws_workspaces_bundle" "windows_10" {
  bundle_id = "wsb-bh8rsxt14" # Value with Windows 10 (English)
}

locals {
  user_csv = csvdecode(file("${path.module}/csv/user.csv"))
  user_csv_data = flatten([
    for new_user in local.user_csv : {
      first_name          = new_user.first_name
      last_name           = new_user.last_name
      enabled             = new_user.enabled
    }
  ])
}
resource "ad_user" "users" {
  count            = length(local.user_csv_data)
  display_name     = "${local.user_csv_data[count.index].first_name} ${local.user_csv_data[count.index].last_name}"
  principal_name   = "${local.user_csv_data[count.index].first_name}${local.user_csv_data[count.index].last_name}"
  sam_account_name = "${local.user_csv_data[count.index].first_name}${local.user_csv_data[count.index].last_name}"
  department       = local.user_csv_data[count.index].class
  description      = local.user_csv_data[count.index].description
  email_address    = local.user_csv_data[count.index].email_address
  given_name       = local.user_csv_data[count.index].first_name
  surname          = local.user_csv_data[count.index].last_name
  enabled          = tobool(local.user_csv_data[count.index].enabled)
  depends_on = [
    module.prov.ad_script
  ]
}

resource "aws_workspaces_workspace" "user_workspace" {
  directory_id = aws_workspaces_directory.workspaces-directory.id
  bundle_id    = data.aws_workspaces_bundle.windows_10.id
  user_name    = "john.doe"

  root_volume_encryption_enabled = true
  user_volume_encryption_enabled = true
  volume_encryption_key          = "alias/aws/workspaces"

  workspace_properties {
    compute_type_name                         = "VALUE"
    user_volume_size_gib                      = 10
    root_volume_size_gib                      = 80
    running_mode                              = "AUTO_STOP"
    running_mode_auto_stop_timeout_in_minutes = 60
  }

  tags = {
    Custodian = "Terraform"
  }
}