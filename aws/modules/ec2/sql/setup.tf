# Create key-pair for logging into EC2 in us-east-1
resource "aws_key_pair" "sqlserver-key" {
  key_name = "sqlserver-key"
  # folder that contains keys but is under gitignore. terraform/aws/keys
  public_key = file("${path.root}/keys/id_rsa.pub")
}

/* # Get Linux AMI ID using SSM Parameter endpoint in us-east-1
data "aws_ssm_parameter" "sqlserver-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}
 */

 # helpful commands
 # get ami id off arn build
 # aws imagebuilder get-image --image-build-version-arn "arn:aws:imagebuilder:us-east-1:aws:image/windows-server-2022-english-full-base-x86/2022.3.9"
 # get owner ID
 # aws ec2 describe-images --image-ids "ami-09a4a092e0d0ed511" --region us-east-1
data "aws_ami" "windows_2022" {
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
  owners = ["801119661308"] # Canonical
}