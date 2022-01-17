[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Livecred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic -AllowRedirection

$identity = Read-Host -Prompt "Enter the Email of the mailbox you wish to remove the Out of Office Reply for"

Import-PSSession $Session 
Connect-MsolService -Credential $LiveCred

    
Set-MailboxAutoReplyConfiguration -Identity $identity -AutoReplyState Disabled