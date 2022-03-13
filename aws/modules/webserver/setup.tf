# Create key-pair for logging into EC2 in us-east-1
resource "aws_key_pair" "webserver-key" {
  key_name   = "webserver-key"
  public_key = file("C:/Users/Almighty/Desktop/id_rsa.pub")
}

# Get Linux AMI ID using SSM Parameter endpoint in us-east-1
data "aws_ssm_parameter" "webserver-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# Create IGW in us-east-1
resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id.id
  tags = {
    Custodian = "managed-by-terraform"
  }
}

# Get main route table to modify
data "aws_route_table" "main_route_table" {
  filter {
    name   = "association.main"
    values = ["true"]
  }
  filter {
    name   = "vpc-id"
    values = [var.vpc_id.id]
  }
}
# Create route table in us-east-1
resource "aws_default_route_table" "internet_route" {
  default_route_table_id = data.aws_route_table.main_route_table.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Custodian = "managed-by-terraform"
    Name = "WebServer-RouteTable"
  }
}

# Get all available AZ's in VPC for master region
data "aws_availability_zones" "azs" {
  state = "available"
}

# Create subnet # 1 in us-east-1
resource "aws_subnet" "subnet" {
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = var.vpc_id.id
  cidr_block        = "10.0.1.0/24"
  tags = {
    Custodian = "managed-by-terraform"
  }
}

# Create SG for allowing TCP/80 & TCP/22
resource "aws_security_group" "sg" {
  name        = "webserver-sg"
  description = "Allow TCP/80 & TCP/22"
  vpc_id      = var.vpc_id.id
  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow traffic from TCP/80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Custodian = "managed-by-terraform"
  }
  lifecycle { 
    # create a new sg in the event this one needs to be modified
    create_before_destroy = true 
    }
}