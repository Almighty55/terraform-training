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

#Create apache guacamole server
resource "aws_instance" "guac" {
  count = 1

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.guacKey.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = var.guac_sg_output.*.id
  subnet_id                   = var.public_subnet_output.id

  provisioner "file" {
    source      = "${path.module}/import_connections.sh"
    destination = "import_connections.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.root}/keys/guacKey")
      host        = self.public_ip
    }
  }
  #! handle multiple sql servers being added to guacamole, right now I am pulling out the first index of the tuple, but it should be dynamic
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install build-essential",
      "sudo apt-get -y upgrade",
      "wget https://git.io/fxZq5 -O guac-install.sh",
      "sudo chmod +x guac-install.sh",
      "sudo chmod +x import_connections.sh",
      "sudo ./guac-install.sh --mysqlpwd password --guacpwd password --nomfa --installmysql",
      "sudo ./import_connections.sh '${var.sqlserver_privateIP[0]}' '${var.sqlserver_pwd_decrypted[0]}'"
      # "mysql -u guacamole_user -ppassword -e 'USE guacamole_db; INSERT INTO guacamole_connection_parameter(connection_id,parameter_name,parameter_value) Values ('1','hostname','${var.sqlserver_privateIP[0]}');'",
      # "mysql -u guacamole_user -ppassword -e 'USE guacamole_db; INSERT INTO guacamole_connection_parameter(connection_id,parameter_name,parameter_value) Values ('1','password','${var.sqlserver_pwd_decrypted[0]}');'"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
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

# resource "aws_ebs_volume" "guac_volume" {
#   availability_zone = aws_instance.guac.availability_zone[count.index]
#   size              = 100
#   tags = {
#     Custodian = "managed-by-terraform"
#     Name      = "guac-volume"
#   }
#   depends_on = [
#     aws_instance.guac
#   ]
# }

# resource "aws_volume_attachment" "ebs_guac" {
#   device_name = "/dev/sdh"
#   volume_id   = aws_ebs_volume.guac_volume.id
#   instance_id = aws_instance.guac.id[count.index]
# }