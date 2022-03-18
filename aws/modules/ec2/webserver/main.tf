#Create and bootstrap webserver
resource "aws_instance" "webserver" {
  #* HOSTNAME SCHEME
  /*
    #? Total of 15 characters MAX but not all have to be used
    #? Note: Domain and company are interchangeble for character limits
    #*  First character designates the domain
          Example: S (silly.net), B (boom.net), X (not bound to a domain)
    #*  First 2 characters designates company 
          Example: A (Almighty LLC), G (Google), Bank of America (BA)
    #*  Next 3 characters designates location either office location for prem or region for cloud
          Example: C1 (Chicago first office), C2 (Chicago second office), UW2 (us-west-2), UE1 (us-east-1)
    #*  Next 1 character designates OS
          Example: W (windows), L (linux), M (macOS), E (embedded firmware)
    #*  Next 1 character designates service level environment
          Example: P (Production), D (Development), T (Testing), U (User Acceptance Testing "UAT"), S (Staging)
    #*  Next 1 character designates internal or external connections
          Example: I (internal), E (external)
   #*   Next 6 characters designates device function
          Example: TS (TermServ), WEBSRV (Website Server), DC (Domain Controller), SQL (SQL Server), FIREWL (Firewall), BAKSRV (Backup Server)
                  APPSRV (Application Server), FS (File Share), HYPVIS (Hypervisor) */

  ami                         = data.aws_ssm_parameter.webserver-ami.value
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.webserver-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.web_sg_output.id]
  subnet_id                   = var.subnet_ouput.id

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y install httpd && sudo systemctl start httpd",
      "echo '<h1><center>Hello World!</center></h1>' > index.html",
      "sudo mv index.html /var/www/html/"
    ]
    connection {
      type = "ssh"
      user = "ec2-user"
      # private key is provided by a cloud guru, nothing special about this ami/server so no security concern
      private_key = file("${path.root}/keys/id_rsa")
      host        = self.public_ip
    }
  }
  tags = {
    Custodian = "managed-by-terraform"
    Name      = "XAUE1LDEWEBSRV"
  }
}