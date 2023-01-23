# Import-Module ActiveDirectory
$domainPath = "OU=goongoblin,DC=goongoblin,DC=tk"
$users = Import-CSV -path "C:\temp\users.csv"

function New-CustomOU ($user) {
    if (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$($user.organizational_unit.ToString())'") {
    } else{
        $ou_path = $user.organizational_unit -Split ",$domainPath"
        $ou_names = $ou_path -Split ',' | Where-Object {$_} | Sort-Object -Descending
        
        if ($ou_names.count -eq 1) {
            $ou = $ou_names
            New-ADOrganizationalUnit -Name $ou.replace('OU=','') -Path "$domainPath"
        } else {
            for ($i; $i -lt $ou_names.count; $i++) {

                $ou = $ou_names[$i -1]
                if ($createdOUs) {
                    $current_path = $createdOUs
                    $checker = $ou+','+$current_path
                } else{
                    $current_path = ($user.organizational_unit -Split "$ou," | Where-Object {$_})[-1]
                    $checker = $ou+','+$current_path
                }

                if (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$checker'") {
                    $createdOUs = "$ou,$current_path"
                } else {
                    New-ADOrganizationalUnit -Name $ou.replace('OU=','') -Path "$current_path"
                    $createdOUs = "$ou,$createdOUs"
                }
            }
        }
            Clear-Variable createdOUs
            Clear-Variable i
    }
}

function Get-RandomPW {
    $lowerCase = 'abcdefghiklmnoprstuvwxyz'
    $upperCase = 'ABCDEFGHKLMNOPRSTUVWXYZ'
    $numbers = '1234567890'
    $special = '~!@#$%^&*()[]<>?'
    $characters = @($lowerCase,$upperCase,$numbers,$special)

    foreach ($character in $characters){
        $random = 1..5 | ForEach-Object { Get-Random -Maximum $character.length } 
        #remove the spaced from the array
        $private:ofs="" 
        #get the random array selection of the $character string
        $pw += [String]$character[$random]
    } 
    #scramble the order so its not always the same
    $characterArray = $pw.ToCharArray()   
    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
    $pw = -join $scrambledStringArray
    $pw = ConvertTo-SecureString $pw -AsPlainText -Force
    return $pw
}

foreach ($user in $users) {
    try{
        New-CustomOU $user
    }
    catch{
    }

    if ([boolean]$user.enabled -eq $true) {
        try{
            Get-ADuser -Identity "$($user.first_name) $($user.last_name)"
        }
        catch{
            New-ADUser -Name "$($user.first_name) $($user.last_name)" -GivenName $user.first_name -Surname $user.last_name -EmailAddress $user.email_address -Description $user.description -Path $user.organizational_unit -Enable $true -Department $user.class -AccountPassword $(Get-RandomPW)
        }
    } elseif ([boolean]$user.enabled -eq $false)  {
        try{
            Get-ADuser -Identity "$($user.first_name) $($user.last_name)"
        }
        catch{
            New-ADUser -Name "$($user.first_name) $($user.last_name)" -GivenName $user.first_name -Surname $user.last_name -EmailAddress $user.email_address -Description $user.description -Path $user.organizational_unit -Enable $false -Department $user.class
        }
    } else{
        Write-Error $_
    }
    

    if ($user.groups) {
        foreach ($group in $user.groups.split(',')) {
            try{
                Get-ADGroup -Identity $group
                Add-ADGroupMember -Identity $group -Members "$($user.first_name) $($user.last_name)"
            }
            catch{
                try {
                    New-ADGroup -Name $group -GroupScope Global -GroupCategory Security -Path "OU=SecurityGroups,$domainPath"
                }
                catch {
                    New-ADOrganizationalUnit -Name "SecurityGroups" -Path "$domainPath"
                    New-ADGroup -Name $group -GroupScope Global -GroupCategory Security -Path "OU=SecurityGroups,$domainPath"
                }
              Add-ADGroupMember -Identity $group -Members "$($user.first_name) $($user.last_name)"
            }
        }
    }
} 