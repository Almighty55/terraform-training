# test aws creds
try {
    Get-STSCallerIdentity | Out-Null
}
catch {
    # once selenium script is finished that should be plugged in here to auto update
    Update-eAWSCreds
} 

Set-Location -Path ..
# Get the bucket name and region from the version.tf configuration
$tfBucket = Get-Content -Path "version.tf" | Select-String "bucket" | Select-Object -ExpandProperty line
$bucketname = ([regex]::match($tfBucket, '(?<=")(?:\\.|[^"\\])*(?=")')).Value

$tfRegion = Get-Content -Path "version.tf" | Select-String "region" | Select-Object -ExpandProperty line
$region = ([regex]::match($tfRegion, '(?<=")(?:\\.|[^"\\])*(?=")')).Value

# create s3 state bucket via cli
aws s3api create-bucket --bucket $bucketName --region $region >$null 2>&1
#* if anything other than us-east-1 then the location constraint is needed
#aws s3api create-bucket --bucket "ENTER_NAME" --region "ENTER_REGION" --create-bucket-configuration LocationConstraint="ENTER_REGION"

# cd to the root then run terraform init
terraform init
terraform apply --auto-approve