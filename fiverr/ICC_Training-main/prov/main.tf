resource "null_resource" "transfer" {
 triggers = {
    always_run = timestamp()
  }
  connection {
      type     = "winrm"
      user     = "goongoblin\\Admin"
      use_ntlm = true
      password = var.password
      host     = var.public_ip[0]
    }

  provisioner "file" {
    source      = "./prov/csv/users.csv"
    destination = "C:/temp/users.csv"
  }

  provisioner "file" {
    source      = "./prov/inline.ps1"
    destination = "C:/temp/inline.ps1"
  }

  provisioner "file" {
    source      = "./prov/User_creation.ps1"
    destination = "C:/temp/User_creation.ps1"
  }
}

locals {
  command = textencodebase64("C:\\temp\\User_creation.ps1", "UTF-8")
}
resource "null_resource" "ad_script" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "remote-exec" {
    inline = ["powershell -file ${textdecodebase64("${local.command}","UTF-8")}"]
    connection {
      type     = "winrm"
      user     = "goongoblin\\Admin"
      password = var.password
      use_ntlm = true
      host     = var.public_ip[0]
    }
    on_failure = continue
  }
  depends_on = [
    null_resource.transfer
  ]
}