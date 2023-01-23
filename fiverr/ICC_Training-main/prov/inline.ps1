# $password = ConvertTo-SecureString -String 'Inductive@22' -AsPlainText -Force;
# $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'test\Admin', $password;
# Start-Process powershell -Credential $cred -ArgumentList ('-file C:\temp\User_creation.ps1')
Start-Process powershell -ArgumentList ('-file C:\temp\User_creation.ps1')