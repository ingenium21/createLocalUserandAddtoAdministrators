$username = "ansi"
$encryptedPassword = Read-host -asSecureString "Enter the Password"
$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($encryptedPassword))

#get list of computers
$servers = get-content .\servers.txt


foreach ($s in $servers) {
   $computer = [ADSI]“WinNT://$s”
   Try {
      $users = $computer.psbase.children | select -expand name  
      if ($users -like $username) {
         Write-Host "$username already exists on $($computer.name)"
         $user_obj.SetPassword($Password)
         Write-Host "Changed the password to what you wanted"
         Write-host "ensuring user is a local admin"
         .\PsExec.exe -accepteula \\$s net localgroup Administrators "$username" /add
      } Else {
         $user_obj = $computer.Create(“user”, “$username”)
         $user_obj.SetPassword($Password)
         $user_obj.SetInfo()
         $user_obj.Put(“description”, “local user for ansible configuration management”)
         $user_obj.SetInfo()
         $user_obj.psbase.invokeset(“AccountDisabled”, “False”)
	     $user_obj.Put("UserFlags", $user_obj.Get("UserFlags") -BOr $UFPwdNeverExpires)
	     $user_obj.Put("UserFlags", $user_obj.Get("UserFlags") -BOr $UFCannotChangePwd)
         $user_obj.SetInfo()
         $users = $computer.psbase.children | select -expand name
         if ($users -like $username) {
            Write-Host "$username has been created on $($computer.name)"
            Write-Host "ensuring user is a local admin"
            .\PsExec.exe -accepteula \\GEN1BLMVC01 net localgroup Administrators "$username" /add
         } Else {
            Write-Host "$username has not been created on $($computer.name)"
         }
      }
   } Catch {
      Write-Host "Error creating $username on $($computer.path):  $($Error[0].Exception.Message)"
   }
}
