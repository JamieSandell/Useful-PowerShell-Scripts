#### Exports a list of all disabled users to Powershell Reports

Get-ADUser -Filter * -Properties DisplayName, EmailAddress | where {($_.EmailAddress -ne $null) -and ($_.Enabled -eq $False) } | Select DisplayName, Emailaddress | Export-CSV \\lan\Netlogon\PowershellReports\DisabledUsers.csv -NoTypeInformation