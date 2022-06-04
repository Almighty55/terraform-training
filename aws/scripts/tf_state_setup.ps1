try {
    # check dependencies 
    if ((Get-Module -ListAvailable -Name AWS* | Where-Object {$_.Name -in "AWS.Tools.S3","AWS.Tools.SecurityToken" }).Name.Count -lt 2){
        Write-Warning "AWS PowerShell Modules not found!`nThis script depends on AWS.Tools.S3 and AWS.Tools.SecurityToken PowerShell Modules."
    }
    if ((Get-Command aws).Name -ne "aws.exe") {
        Write-Warning "AWS CLI V2 not found!`nThis script depends on AWS.Tools.S3 and AWS.Tools.SecurityToken PowerShell Modules."
        exit
    }

    # test aws creds
    try {
        Get-STSCallerIdentity | Out-Null
    }
    catch {
        Write-Host "Attempting to get AWS Creds from A Cloud Guru..."
        # once selenium script is finished that should be plugged in here to auto update
        # & "C:/Program Files/Python39/python.exe" "./ACloudGuru_AWS_Sandbox.py"

        try {
            Get-STSCallerIdentity | Out-Null
        }
        catch {
            Write-Warning "Getting Creds was unsuccessful.`nPlease manually update AWS creds"
            exit
        }
    }

    # move to the proper directory and retain their current directory
    Push-Location -Path (Split-Path $MyInvocation.MyCommand.Path)
    Set-Location -Path ..

    $leftOvers = @( ".terraform",
                    "errored.tfstate",
                    ".terraform.lock.hcl",
                    "terraform.tfstate",
                    ".infracost")
    foreach ($path in $leftOvers) {
        if (Test-Path -Path $path) {
            Write-Warning "Taint files found!`nPlease clean up by running tf_destroy.ps1 before the setup."
            exit
        }
    }

    # Get the bucket name and region from the version.tf configuration
    $tfBucket = Get-Content -Path "version.tf" | Select-String "bucket" | Select-Object -ExpandProperty line
    $bucketname = ([regex]::match($tfBucket, '(?<=")(?:\\.|[^"\\])*(?=")')).Value

    $tfRegion = Get-Content -Path "version.tf" | Select-String "region" | Select-Object -ExpandProperty line
    $region = ([regex]::match($tfRegion, '(?<=")(?:\\.|[^"\\])*(?=")')).Value
    if (!(Test-S3Bucket $bucketname)) {
        # create s3 state bucket via cli
        if ($region -eq "us-east-1") {
            aws s3api create-bucket --bucket $bucketName --region $region >$null 2>&1
            aws s3api put-public-access-block --bucket $bucketName --region $region --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" >$null 2>&1
            aws s3api put-bucket-versioning --bucket $bucketName --versioning-configuration MFADelete=Disabled,Status=Enabled >$null 2>&1
        }
        else {
            # if anything other than us-east-1 then the location constraint is needed
            aws s3api create-bucket --bucket $bucketName --region $region --create-bucket-configuration LocationConstraint=$region >$null 2>&1
            aws s3api put-public-access-block --bucket $bucketName --region $region --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" >$null 2>&1
            aws s3api put-bucket-versioning --bucket $bucketName --versioning-configuration MFADelete=Disabled,Status=Enabled >$null 2>&1
        }
    }
    else{
        Write-Warning "'$bucketname' is not available!`nPlease use a different name and verify it is available:`nTest-S3Bucket 'bucketname'"
        exit
    }
    

    # cd to the root then run terraform init
    terraform init
    terraform apply --auto-approve
    # back into their start directory
    Pop-Location
}
catch {
    Write-Warning "There was an error with the setup, please make sure the following are valid:
    1. bucketname
    2. region
    3. aws creds"
}