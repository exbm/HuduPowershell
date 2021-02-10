#####################################################################
$TOKEN = "HUDU API KEY"
$URL = "HUDU SITE URL"
$orgID = "ORGIDHERE"
$ChangeAdminUsername = $true
$NewAdminUsername = "Test"
#####################################################################

Import-Module C:\hudumodule.psm1 -Force
#This is the process we'll be perfoming to set the admin account.

$LocalAdminPassword = [System.Web.Security.Membership]::GeneratePassword(24,5)

If($ChangeAdminUsername -eq $false) {

	Set-LocalUser -name "Administrator" -Password ($LocalAdminPassword | ConvertTo-SecureString -AsPlainText -Force) -PasswordNeverExpires:$true

} else {

	$ExistingNewAdmin = get-localuser | Where-Object {$_.Name -eq $NewAdminUsername}

	if(!$ExistingNewAdmin){

		write-host "Creating new user" -ForegroundColor Yellow
		New-LocalUser -Name $NewAdminUsername -Password ($LocalAdminPassword | ConvertTo-SecureString -AsPlainText -Force) -PasswordNeverExpires:$true

		Add-LocalGroupMember -Group Administrators -Member $NewAdminUsername

		Disable-LocalUser -Name "Administrator"

	} else {
 		write-host "Updating admin password" -ForegroundColor Yellow
 		set-localuser -name $NewAdminUsername -Password ($LocalAdminPassword | ConvertTo-SecureString -AsPlainText -Force)
	}
} #>

if($ChangeAdminUsername -eq $false ) { $username = "Administrator" } else { $Username = $NewAdminUsername }



#The script uses the following line to find the correct asset by serialnumber, match it, and connect it if found. Don't want it to tag at all? Comment it out by adding #

$Asset = Find-HuduAssetbySerial -token $token -url $URL -primary_serial (get-ciminstance win32_bios).serialnumber
Write-Warning $Asset.id

$COMPANYID = $Asset.company_id
$ASSETID = $Asset.id

$Passwords = (Get-HuduPasswords -token $TOKEN -url $URL -page_size 100).asset_passwords

$PasswordObjectName = "$($Env:COMPUTERNAME) - Local Administrator Account"


$PasswordObject = @{
    token = $TOKEN
    url = $URL
    passwordable_type = 'Asset'
    passwordable_id = $ASSETID
    company_id = $COMPANYID
    name = $PasswordObjectName
    username = $Username
    password = $LocalAdminPassword
}

#Now we'll check if it already exists, if not. We'll create a new one.

$ExistingPassword = ($Passwords | ? { $_.name -eq $PasswordObjectName })

#If the Asset does not exist, we edit the body to be in the form of a new asset, if not, we just upload.

if(!$ExistingPassword){

	Write-Host "Creating new Local Administrator Password" -ForegroundColor yellow
	New-HuduPassword @PasswordObject

} else {

	Write-Host "Updating Local Administrator Password" -ForegroundColor Yellow
    $PasswordObject.Add("id", ($ExistingPassword| Select-Object -Last 1).id)
	Set-HuduPassword @PasswordObject
}
