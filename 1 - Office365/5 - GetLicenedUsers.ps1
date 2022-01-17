[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Write-Host "================ Assign a user to a shared mailbox ================"

$Livecred = Get-Credentials
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic -AllowRedirection

#Connect to office365
Import-PSSession $Session 
Connect-MsolService -Credential $LiveCred


#Add licenced users and svae in powershell reports as CSV

Get-MsolUser | Where-Object { $_.isLicensed -eq "TRUE" } | Export-Csv "c:\temp\LicencedUsers.csv"