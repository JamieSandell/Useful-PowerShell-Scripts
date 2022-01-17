[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Host "================ Assign a user to a shared mailbox ================"

#Stores encypted credentials
$tech = Read-Host -Prompt "Enter IT Admin first name"
$Pass = Get-Content ".\O365_Credentials$tech.txt" | ConvertTo-SecureString
$Livecred = New-Object -typename System.Management.Automation.PSCredential -ArgumentList $tech, $Pass
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic -AllowRedirection

#Connect to office365
Import-PSSession $Session 
Connect-MsolService -Credential $LiveCred

Remove-PSSession $Session