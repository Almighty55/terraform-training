
try {
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
    if ($region -eq "us-east-1") {
        #TODO: Add in error handling to catch if the bucket name is conflicting
        #! An error occurred (OperationAborted) when calling the CreateBucket operation: A conflicting conditional operation is currently in progress against this resource. Please try again.
        aws s3api create-bucket --bucket $bucketName --region $region >$null 2>&1
    }
    else {
        # if anything other than us-east-1 then the location constraint is needed
        aws s3api create-bucket --bucket $bucketName --region $region --create-bucket-configuration LocationConstraint=$region >$null 2>&1
    }

    # cd to the root then run terraform init
    terraform init
    terraform apply --auto-approve
    # back into the script directory
    Set-Location -Path -
}
catch {
    Write-Error "There was an error with the setup, please make sure the following are valid:
    1. bucketname
    2. region
    3. aws creds"
}