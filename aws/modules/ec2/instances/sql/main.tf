/* helpful commands
  get ami id off arn build
  aws imagebuilder get-image --image-build-version-arn "arn:aws:imagebuilder:us-east-1:aws:image/windows-server-2022-english-full-base-x86/2022.3.9"
  get owner ID
  aws ec2 describe-images --image-ids "ami-09a4a092e0d0ed511" --region us-east-1 */
data "aws_ami" "windows_2022" {
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
  owners = ["801119661308"] # AWS owner ID
}

# Create key-pair for logging into EC2 in us-east-1
resource "aws_key_pair" "sqlserver-key" {
  key_name = "sqlserver-key"
  # folder that contains keys but is under gitignore. terraform/aws/keys
  public_key = file("${path.root}/keys/id_rsa.pub")
}

#Create sqlserver
resource "aws_instance" "sqlserver" {
  count = 2
  #* HOSTNAME SCHEME
  /*
    #? Total of 17 characters MAX but not all have to be used
    #? Note: Domain and company are interchangeble for character limits
    #*  First character designates the domain
          Example: S (silly.net), B (boom.net), X (not bound to a domain)
    #*  First 2 characters designates company 
          Example: A (Almighty LLC), G (Google), Bank of America (BA)
    #*  Next 3 characters designates location either office location for prem or region for cloud
          Example: C1 (Chicago first office), C2 (Chicago second office), UW2 (us-west-2), UE1 (us-east-1)
    #*  Next 1 character designates OS
          Example: W (windows), L (linux), M (macOS), E (embedded firmware)
    #*  Next 1 character designates internal or external connections
          Example: I (internal), E (external)
    #*  Next 1 character designates service level environment
          Example: P (Production), D (Development), T (Testing), U (User Acceptance Testing "UAT"), S (Staging)
    #*   Next 6 characters designates device function
          Example: TS (TermServ), WEBSRV (Website Server), DC (Domain Controller), SQL (SQL Server), FIREWL (Firewall), BAKSRV (Backup Server)
                   APPSRV (Application Server), FS (File Share), HYPVIS (Hypervisor)
    #*   Next 2 characters designates the server number or version starting at "01"
          Example: XAUE1LDISQL01, XAUE1LDISQL02, XAUE1LDEWEBSRV01, XAUE1LDEWEBSRV02*/
  ami                         = data.aws_ami.windows_2022.id
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.sqlserver-key.key_name
  associate_public_ip_address = false
  vpc_security_group_ids      = [var.sql_sg_output.id]
  subnet_id                   = var.private_subnet_output.id
  user_data                   = file("${path.module}/build_script.txt")
  user_data_replace_on_change = true
  # user_data         = <<EOF
  # <powershell>
  # Set-DnsClientServerAddress -InterfaceAlias  "Ethernet" -ServerAddresses ("${sort(var.aws_managed_ad_output.dns_ip_addresses)[0]}","${sort(var.aws_managed_ad_output.dns_ip_addresses)[1]}")
  # Add-Computer -DomainName ${var.aws_managed_ad_output.name} -Credential (New-Object -TypeName PSCredential -ArgumentList "Admin",(ConvertTo-SecureString -String 'Sup3rS3cr3tP@ssw0rd' -AsPlainText -Force)[0])
  # New-Item -Path $env:USERPROFILE\Desktop\test.txt

  # Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0
  # Restart-Service wuauserv
  # Install-WindowsFeature -Name "RSAT-AD-PowerShell" -IncludeAllSubFeature
  # Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 1
  # Restart-Service wuauserv

  # $password = ConvertTo-SecureString -String "Sup3rS3cr3tP@ssw0rd" -AsPlainText -Force
  # $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "testAD\Admin", $password

  # $suppliedArgs = '-noprofile -command "Import-Module -Name ActiveDirectory;
  # New-ADUser -Name "TestUser" -Accountpassword (ConvertTo-SecureString -String "Sup3rS3cr3tP@ssw0rd" -AsPlainText -Force) -Enabled $true"'
  # Start-Process powershell.exe -Credential $cred -WindowStyle Hidden -ArgumentList $suppliedArgs -RedirectStandardOutput $env:USERPROFILE\Desktop\log.txt -RedirectStandardError $env:USERPROFILE\Desktop\log_error.txt

  # $suppliedArgs = '-noprofile -command "Get-ADUser TestUser"'
  # Start-Process powershell.exe -Credential $cred -WindowStyle Hidden -ArgumentList $suppliedArgs -RedirectStandardOutput $env:USERPROFILE\Desktop\log.txt -RedirectStandardError $env:USERPROFILE\Desktop\log_error.txt
  # </powershell>
  # EOF
  get_password_data = "true"

  tags = {
    Custodian = "managed-by-terraform"
    # nested terraform if else logic, but it checks if a '0' should be appended or not
    # ${count.index} starts at 0 so the '9' condition would technically be the 10th server
    Name = count.index == 0 ? "XAUE1WIDSQL01" : count.index >= 9 ? "XAUE1WIDSQL${count.index + 1}" : "XAUE1WIDSQL0${count.index + 1}"
  }
}