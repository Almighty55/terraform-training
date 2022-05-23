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

Set-Location -Path ..
# auto approve destroy and hide output since it would error out for saving state file
terraform destroy --auto-approve
if (Test-Path ".terraform") {
    Remove-Item -Path ".terraform" -Recurse -Force
}
if (Test-Path "errored.tfstate") {
    Remove-Item -Path "errored.tfstate" -Recurse -Force
}
if (Test-Path ".terraform.lock.hcl") {
    Remove-Item -Path ".terraform.lock.hcl" -Recurse -Force
}
if (Test-Path "terraform.tfstate") {
    Remove-Item -Path "terraform.tfstate" -Recurse -Force
}
if (Test-Path ".infracost") {
    Remove-Item -Path ".infracost" -Recurse -Force
}

# purge aws creds
$accessKeyID = ""
$secretAccessKey = ""
$newCreds = @("[default]", "aws_access_key_id = $accessKeyID", "aws_secret_access_key = $secretAccessKey")
#Set-Content -path "C:\Users\$env:USERNAME\.aws\credentials" -Value $newCreds
  
Write-Host -BackgroundColor Black -ForegroundColor Yellow "WARNING: Terraform backend has been destroyed.`nPlease run tf_state_setup.ps1 to setup backend again."
# back into the script directory
Set-Location -Path -