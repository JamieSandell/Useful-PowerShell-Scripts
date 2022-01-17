Import-Module -Name '..\Email.psm1'

$body = "$env:COMPUTERNAME has the Windows 10 1803 AppData folder redirection bug."
$body += "`n"
$body += "This means the user's (roaming) appdata folder will not have redirected for them."
$body += "`n"
$body += 'To fix this please deploy the latest CU update for 1803 to their PC via PDQ Deploy'

$from = 'proactive@contoso.com'

$subject = "$env:COMPUTERNAME has the Windows 10 1803 AppData folder redirection bug."

$to = 'helpdesk@contoso.com'

Send-MailMessage -Body $body -From $from -Subject $subject -To $to

Remove-Module -Name Email