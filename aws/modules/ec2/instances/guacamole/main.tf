# Get Linux AMI ID using SSM Parameter endpoint in us-east-1
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  owners = ["099720109477"] # Ubuntu owner ID
}

# # Create key-pair for logging into EC2 in us-east-1
resource "aws_key_pair" "guacKey" {
  key_name = "guacKey"
  # folder that contains keys but is under gitignore. terraform/aws/keys
  # ssh-keygen.exe -t rsa -b 2048
  public_key = file("${path.root}/keys/guacKey.pub")
}

#Create and bootstrap webserver
resource "aws_instance" "guac" {
  count = 1
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

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.guacKey.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = var.guac_sg_output.*.id
  subnet_id                   = var.public_subnet_output.id

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install build-essential",
      "wget https://git.io/fxZq5 -O guac-install.sh",
      "sudo chmod +x guac-install.sh",
      "sudo ./guac-install.sh --mysqlpwd password --guacpwd password --nomfa --installmysql"
    ]
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file("${path.root}/keys/guacKey")
      host        = self.public_ip
    }
  }

  tags = {
    Custodian = "managed-by-terraform"
    # nested terraform if else logic, but it checks if a '0' should be appended or not
    # ${count.index} starts at 0 so the '9' condition would technically be the 10th server
    Name = "${count.index}" == 00 ? "XAUE1LEDGUACSRV01" : "${count.index}" >= 9 ? "XAUE1LEDGUACSRV${count.index + 1}" : "XAUE1LEDGUACSRV0${count.index + 1}"
  }
}