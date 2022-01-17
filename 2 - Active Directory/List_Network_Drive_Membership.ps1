$ListGroup = Get-ADGroup -SearchBase "OU=Network Drives, OU=Security Groups,DC=LAN, DC=contoso,DC=COM" -filter {GroupCategory -eq "Security"} | Select Name | out-host
Write-Output "$ListGroups" | out-host
$Group =  Read-Host -Prompt 'Please input the Security Group from the list above that you would like to query'
Get-ADGroupMember -identity "$Group" | Select Name | Export-CSV .\$Group.csv -NoTypeInformation 
Import-CSV .\$Group.csv