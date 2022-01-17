[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Write-Host "================ Assign a user to a shared mailbox ================"

$Livecred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic -AllowRedirection

#set email address of the shared mailbox
$EmailAddressFrom =  Read-Host -Prompt 'Please input the E-mail address you would like to forward from'

#Email address of user that you would like to assign the shared mailbox to
$EmailAddressTo=  Read-Host -Prompt 'Please input the Email address of user that you the emails to go to'

#Connect to office365
Import-PSSession $Session 
Connect-MsolService -Credential $LiveCred


#Add user pemrissions to shared mailbox
Add-MailboxPermission -Identity "$EmailAddressFrom" -User "$EmailAddressTo" -AccessRights FullAccess -InheritanceType All

$SendAs = Read-Host -Prompt "Would you like to give this user send permissions for this mailbox? (Y/N)"

if($SendAs -eq "Y")
{
    Add-RecipientPermission "$EmailAddressFrom" -AccessRights SendAs -Trustee "$EmailAddressTo"
    Start-Sleep 1
}
else
{
    Write-Output "Proceeding to next step"
    Start-Sleep 1
}

for($i = 0; $i -le 100; $i++)
{
 Write-Progress -Activity "Permissions have been applied Powershell will now check the current permissions on the mailbox, please wait" -PercentComplete $i -Status "Processing";
 Sleep -Milliseconds 30;
}

#Check Mailbox Permissions
Get-MailboxPermission -Identity "$EmailAddressFrom"
Read-Host 'Press Enter to exit...' 
Get-PSSession | Remove-PSSession