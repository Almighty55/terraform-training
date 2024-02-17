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
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.guacKey.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = var.guac_sg_output.*.id
  subnet_id                   = var.public_subnet_output.id

  tags = {
    Custodian = "managed-by-terraform"
    Name      = "XAUE1LEDGUAC01"
  }

  provisioner "file" {
    source      = "${path.module}/guacamole-install/1-setup.sh"
    destination = "1-setup.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.root}/keys/guacKey")
      host        = self.public_ip
    }
  }

  #TODO get this to trigger on any changes to sql server and add in jump server config
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x 1-setup.sh",
      "sudo ./1-setup.sh '${join(",", var.sqlserver_privateIP)}' '${join(",", var.sqlserver_pwd_decrypted)}'"
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