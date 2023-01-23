#############################################
# Instances
#############################################

#? Answer to #2 self guided
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  owners = ["amazon"]
}

#Create EC2 Instance
resource "aws_instance" "webserver" {
  count                  = length(var.aws_availability_zones)
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"                                             #? Answer to #2 self guided
  availability_zone      = element(sort(var.aws_availability_zones), count.index) #? Answer to #3 Online
  vpc_security_group_ids = [aws_security_group.webserver-sg.id]
  subnet_id              = aws_subnet.web-subnet[count.index].id
  user_data              = file("install_apache.sh") #? Answer to #2 self guided

  # root disk
  root_block_device {
    volume_size           = "20"
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  # data disk
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = "50"
    volume_type           = "gp3" #? Answer to #2 self guided
    encrypted             = true  #? Answer to #2 self guided
    delete_on_termination = true
  }
}