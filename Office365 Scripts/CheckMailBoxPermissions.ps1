[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#This script will check the permissions on a shared mailbox

$Livecred = Get-Credential

Import-Module MSOnline 
Connect-MsolService -Credential $Livecred 
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Livecred -Authentication Basic -AllowRedirection


#set email address of the shared mailbox
$EmailAddress =  Read-Host -Prompt 'Please input the shared mailbox E-mail address that you would like to check'

#Connect to office365
Import-PSSession $Session 
Connect-MsolService -Credential $LiveCred

#Check Mailbox Permissions
Get-MailboxPermission -Identity "$EmailAddress"


Read-Host 'Press Enter to exit...' 
Get-PSSession | Remove-PSSession
