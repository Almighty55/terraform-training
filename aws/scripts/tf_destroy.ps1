$title    = "Reset Terraform Backend"
$question = "This script will delete your backend bucket and reset your tf environemnt.`nAre you sure you want to proceed?"
$choices  = @('&Yes', '&No')

$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
if ($decision -eq 0) {
    Write-Host "confirmed"
}
else {
    exit
}

# move to the proper directory and retain their current directory
Push-Location -Path (Split-Path $MyInvocation.MyCommand.Path)
Set-Location -Path ..

# auto approve destroy 
Invoke-Expression -Command "terraform destroy --auto-approve"

#clean up any left over files
$leftOvers = @( ".terraform",
                "errored.tfstate",
                ".terraform.lock.hcl",
                "terraform.tfstate",
                ".infracost")
foreach ($path in $leftOvers) {
    if (Test-Path -Path $path) {
        Remove-Item -Path $path -Recurse -Force
    }
}

# purge aws creds
$accessKeyID = ""
$secretAccessKey = ""
$newCreds = @("[default]", "aws_access_key_id = $accessKeyID", "aws_secret_access_key = $secretAccessKey")
#Set-Content -path "C:\Users\$env:USERNAME\.aws\credentials" -Value $newCreds
  
Write-Host -BackgroundColor Black -ForegroundColor Yellow "WARNING: Terraform backend has been destroyed.`nPlease run tf_state_setup.ps1 to setup backend again."
# back into their start directory
Pop-Location