$accessKeyID = $args[0]
$secretAccessKey = $args[1]
$newCreds = @("[default]", "aws_access_key_id = $accessKeyID", "aws_secret_access_key = $secretAccessKey")
Set-Content -path "C:\Users\$env:USERNAME\.aws\credentials" -Value $newCreds