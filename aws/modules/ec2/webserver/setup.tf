# Create key-pair for logging into EC2 in us-east-1
resource "aws_key_pair" "webserver-key" {
  key_name = "webserver-key"
  # folder that contains keys but is under gitignore. terraform/aws/keys
  public_key = file("${path.root}/keys/id_rsa.pub")
}

# Get Linux AMI ID using SSM Parameter endpoint in us-east-1
data "aws_ssm_parameter" "webserver-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}