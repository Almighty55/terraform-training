# Create key-pair for logging into EC2 in us-east-1
resource "aws_key_pair" "sqlserver-key" {
  key_name = "sqlserver-key"
  # folder that contains keys but is under gitignore. terraform/aws/keys
  public_key = file("${path.root}/keys/id_rsa.pub")
}