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

locals {
  connections = [for i in range(length(var.sqlserver_privateIP)) : {
    ip        = var.sqlserver_privateIP[i]
    decrypted = var.sqlserver_pwd_decrypted[i]
  }]

  tmpl = <<-EOT
    %{for c in local.connections~}*Connection*
    ${c.ip}
    ${c.decrypted}

    %{endfor~}
  EOT
}

resource "local_file" "foo" {
  content  = local.tmpl
  filename = "${path.module}/private_ips.txt"
}

#Create apache guacamole server
resource "aws_instance" "guac" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.guacKey.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = var.guac_sg_output.*.id
  subnet_id                   = var.public_subnet_output.id

  tags = {
    Custodian = "managed-by-terraform"
    Name      = "XAUE1LEDGUACSRV01"
  }
}

#TODO grab the data from local.tmpl and build a new import_connections script that can handle that format
#TODO get this to trigger on any changes to sql server and add in jump server config
resource "null_resource" "guac_setup"{
    triggers {
      version = "${timestamp()}" 
    }
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
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.root}/keys/guacKey")
      host        = aws_instance.guac.public_ip
    }
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