Import-Module '..\Powershell Modules\Email.psm1'

# Queries WSUS for any computers that have an error state reported
$wsusResults = Get-WsusServer -Name WSUS1 -PortNumber 8530 | Get-WsusComputer -ComputerTargetGroups "All Computers"  -IncludedInstallationStates Failed -IncludeSubgroups
if($wsusResults -eq "No Computers available.")
{
    $body = "There are no computers reporting errors in WSUS."
}
Else
{
    $body = "There are computers reporting errors in WSUS."
}

# Create message, add From mailaddress with custom display name
$from = 'alerts@contoso.com'
$to = 'helpdesk@contoso.com'
$subject = "WSUS Computer Error Report"

Send-MailMessage -From $from -To $to -Subject $subject -Body $body

Remove-Module -Name Email