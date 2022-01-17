[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#This script will check the permissions on a shared mailbox

Write-Host "=============== Check permissions on a shared mailbox ================="

$Livecred = Get-Credential
Import-Module MSOnline 
Connect-MsolService -Credential $Livecred 
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Livecred -Authentication Basic -AllowRedirection

#Connect to office365
Import-PSSession $Session 
Connect-MsolService -Credential $LiveCred

Get-Mailbox -Identity joe.bloggs@contoso.com | Format-List RecipientTypeDetails


