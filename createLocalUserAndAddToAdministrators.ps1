$Password = Read-host -asSecureString "Enter the Password" 

#get list of computers
$servers = get-content .\servers.txt


foreach ($s in $servers) {invoke-command -computerName $s -scriptBlock {
New-LocalUser "ansi" -Password $Password -FullName "ansi" -Description "this user is created for ansible" -AccountNeverExpires -PasswordNeverExpires;
Add-LocalGroupMember -Group "Administrators" -Member "ansi"
}}