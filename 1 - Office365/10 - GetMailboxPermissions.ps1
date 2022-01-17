[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#This script will check the permissions on a shared mailbox

Write-Host "=============== Check permissions of a mailbox ================="

$Livecred = Get-Credential

Import-Module MSOnline 
Connect-MsolService -Credential $Livecred 
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Livecred -Authentication Basic -AllowRedirection
Import-PSSession $Session 

Get-Content -path 'C:\temp\mailboxes.txt' | get-mailbox | Get-MailboxPermission | ? {($_.User -ne "NT AUTHORITY\SELF") -and ($_.IsInherited -ne $true)} | Out-GridView # full access
Get-Content -path 'C:\temp\mailboxes.txt' | Get-RecipientPermission | Where { -not ($_.Trustee -like “nt authority\self”) } | Out-GridView #send as and send on behalf of

Remove-PSSession $Session
