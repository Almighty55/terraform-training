# create s3 state bucket via cli
aws s3api create-bucket --bucket "alaraj-terraform-state1" --region "us-east-1"
#* if anything other than us-east-1 then the location constraint is needed
#aws s3api create-bucket --bucket "alaraj-terraform-state1" --region "us-east-2" --create-bucket-configuration LocationConstraint="us-east-2"
# cd to the root then run terraform init
Set-Location -Path ..
terraform init
terraform apply --auto-approve