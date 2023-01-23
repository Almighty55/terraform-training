data "aws_secretsmanager_secret" "secrets" {
  name = "Domain"
}
data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.secrets.id
}
locals {
  # password = sensitive(jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["password"])
  password = "Test@123"

}

data "aws_ami" "windows_2022" {
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
  owners = ["801119661308"] # AWS owner ID
}

resource "aws_key_pair" "windows_pub_key" {
  key_name   = "windows_pub_key"
  public_key = file("${path.root}/keys/id_rsa.pub")
}

resource "aws_instance" "windows_pub" {
  count                       = 0
  ami                         = data.aws_ami.windows_2022.id
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.windows_pub_key.key_name
  vpc_security_group_ids      = [var.windows_pub_sg_output.id]
  subnet_id                   = var.public_subnet_output.id
  associate_public_ip_address = true
  # user_data_replace_on_change = true
  user_data                   = <<EOF
  <powershell>
  winrm quickconfig -q
  winrm set winrm/config/service '@{AllowUnencrypted="true"}'
  winrm set winrm/config/service/auth '@{Basic="true"}'

  netsh advfirewall firewall add rule name="WinRM 5985" protocol=TCP dir=in localport=5985 action=allow
  netsh advfirewall firewall add rule name="WinRM 5986" protocol=TCP dir=in localport=5986 action=allow
  New-SelfSignedCertificate -DnsName goongoblin.tk -CertStoreLocation Cert:\LocalMachine\My
  net stop winrm
  cmd /c 'sc config WinRM start= auto'
  net start winrm

  Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine -Force

  try{
    Set-DnsClientServerAddress -InterfaceAlias  "Ethernet" -ServerAddresses ("${sort(var.aws_managed_ad_output.dns_ip_addresses)[0]}","${sort(var.aws_managed_ad_output.dns_ip_addresses)[1]}")
  }
  catch{
    Set-DnsClientServerAddress -InterfaceAlias  "Ethernet 2" -ServerAddresses ("${sort(var.aws_managed_ad_output.dns_ip_addresses)[0]}","${sort(var.aws_managed_ad_output.dns_ip_addresses)[1]}")
  }
  Add-Computer -DomainName ${var.aws_managed_ad_output.name} -Credential (New-Object -TypeName PSCredential -ArgumentList "Admin",(ConvertTo-SecureString -String '${local.password}' -AsPlainText -Force)[0])
  Add-LocalGroupMember -Group Administrators -Member "goongoblin\Admin"
  Add-LocalGroupMember -Group "Remote Desktop Users" -Member "goongoblin\Admin"

  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0
  Restart-Service wuauserv
  Install-WindowsFeature -Name "RSAT-AD-Tools" -IncludeAllSubFeature
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 1
  Restart-Service wuauserv
  New-Item -Path "c:\" -Name "temp" -ItemType "directory"
  $path = 'C:\temp'
  $acl = Get-Acl -Path $path
  $accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule ('Everyone', 'FullControl', 'ContainerInherit, ObjectInherit', 'InheritOnly', 'Allow')
  $acl.SetAccessRule($accessrule)
  Set-Acl -Path $path -AclObject $acl
  </powershell>
EOF
  # get_password_data           = "true"

  tags = {
    Custodian = "managed-by-terraform"
  }

  # depends_on = [
  #   var.aws_managed_ad_output
  # ]
}