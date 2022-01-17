Import-Module "..\Powershell Modules\Logging.psm1"

$date = (Get-Date).ToString("dd-MM-yyyy")
Start-Logging -logFile ".\$date.txt"

#region SetGPOPermissions
#Uses RegEx to get the Desk letter the computer belongs too.
$String = (Get-ADComputer -Identity $env:COMPUTERNAME).DistinguishedName
$Regex = [Regex]::new("(?<=CN=$ENV:COMPUTERNAME,OU=Desk Block )(.*)(?=,OU=Desktops)")            
$Match = $Regex.Match($String).Value         

#Sets 'Read' and 'Deny' permissions on the printer GPO that this desktop belongs too.
$gpo = Get-GPO -Name "Printers - Desk $Match"
$adgpo = [ADSI]"LDAP://CN=`{$($gpo.Id.guid)`},CN=Policies,CN=System,DC=lan,DC=contoso,DC=Com"
$rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
  [System.Security.Principal.NTAccount]"LAN\$ENV:COMPUTERNAME$",
  "ExtendedRight",
  "Deny",
  [Guid]"edacfd8f-ffb3-11d1-b41d-00a0c968f939"
 )

$acl = $adgpo.ObjectSecurity
$acl.AddAccessRule($rule)
$adgpo.CommitChanges()
Set-GPPermission -Name $gpo.DisplayName -TargetName $env:COMPUTERNAME -TargetType Computer -PermissionLevel GpoRead |Out-Null
#endregion SetGPOPermissions

#Performs a gpupdate with no restart or logoff
cmd.exe /c "..\gpupdate.bat"

#Stops the print spooler service
Stop-Service -Name Spooler

#region DeleteFoldersandKeys
#Checks to see if the Canon LBP252 printer driver folder and corresponding registry key exists, and then removes then removes them.
$DriverKey = Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Environments\Windows x64\Drivers\Version-3\Canon LBP252 PCL6"

If($DriverKey -eq "True")
{
    Remove-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Environments\Windows x64\Drivers\Version-3\Canon LBP252 PCL6" -Force -Confirm:$false -Recurse
}
Else
{
    Write-Output "The registry key does not exist so it cannot be deleted."
}

$DriverFolder = Test-Path -Path "C:\Windows\System32\spool\drivers\x64\3"

If($DriverFolder -eq "True")
{
    Remove-Item "C:\Windows\System32\spool\drivers\x64\3" -Force -Confirm:$false -Recurse
}
Else
{
   Write-Output "The folder does not exist either so this cannot be deleted."

}
#endregion DeleteFolderandKeys

#Starts the print spooler service again
Start-Service -Name Spooler

#Removes the Read/Deny permissions set earlier
Set-GPPermission -Name $gpo.DisplayName -TargetName $env:COMPUTERNAME -TargetType Computer -PermissionLevel None |Out-Null

Stop-Logging

Restart-Computer -Force