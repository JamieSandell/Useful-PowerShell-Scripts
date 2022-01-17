param([switch]$email)

function Email-Helpdesk()
{
    Write-Output "E-mailed"
}

Import-Module -Name '..\powershell modules\Email.psm1'
Import-Module '..\powershell modules\SecureCredentials.psm1'
$UserCredential = Get-Credentials
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication  Basic -AllowRedirection
Import-PSSession $Session


$myObjects = @()

$mailboxes = Get-Mailbox


foreach ($mailbox in $mailboxes)
{
    Write-Output "Processing mailbox `t $($mailbox.PrimarySmtpAddress)"
    $cas = $mailbox.PrimarySmtpAddress | Get-CASMailbox -ErrorAction SilentlyContinue


    $myObjects += [PSCustomObject]@{
                'PrimarySmtpAddress' = $mailbox.PrimarySmtpAddress
                'RecipientTypeDetails' = $mailbox.RecipientTypeDetails
                'EwsEnabled' = $cas.EwsEnabled                
                'PopEnabled' = $cas.PopEnabled
                'ImapEnabled' = $cas.ImapEnabled
                'ActiveSyncEnabled' = $cas.ActiveSyncEnabled
                'OWAEnabled' = $cas.OWAEnabled
                'OWAforDevicesEnabled' = $cas.OWAforDevicesEnabled
            }
    Write-Output "Processed mailbox `t $($mailbox.PrimarySmtpAddress)"
}

$exportPath = "C:\temp\GetMailboxCAS.csv"
$myObjects | Export-CSV -Path $exportPath -NoTypeInformation
if ((Test-Path $exportPath) -eq $true)
{
    Write-Output "Details exported to $exportPath"
}
else
{
    Write-Error "Failed to export details to $exportPath"
}

Write-Output $email
if ($email)
{
    Email-Helpdesk
    $objectsToEmail = @()

    foreach($object in $myObjects)
    {
        if (($object.PopEnabled -eq "TRUE") -or ($object.ImapEnabled -eq "TRUE") -or ($object.ActiveSyncEnabled -eq "TRUE") -or ($object.OWAEnabled -eq "TRUE") -or ($object.OWAforDevicesEnabled -eq "TRUE"))
        {
            $objectsToEmail += $object
        }
    }

    if ($objectsToEmail.count -gt 0) #found at least 1 matching object?
    {
        $exportPath = "C:\temp"
        $exportFile = "GetMailboxCAS.CSV"
        if ((Test-Path -Path $exportPath) -eq $false)
        {
            New-Item -Path $exportPath
        }
        $objectsToEmail | Export-Csv -Path ($exportPath+$exportFile) -NoTypeInformation

        $emailAttachment = ($exportPath+$exportFile)
        $emailBody = "One or more mailboxes have one or more of the following enabled: POP, IMAP, ActiveSync, OWA and OWA for Devices`n`n
                        Please see the attached CSV file."
        $emailSubject = "One or more mailboxes have one or more of the following enabled: POP, IMAP, ActiveSync, OWA and OWA for Devices"
        $emailFrom = "proactive@cyclops-electronics.com"
        $emailTo = "helpdesk@cyclops-electronics.com"

        Send-MailMessage -Attachments $emailAttachment -Body $emailBody -From $emailFrom -To $emailTo -Subject $emailSubject
    }

    Write-Output $objectsToEmail
}

Remove-PSSession $Session

Remove-Module -Name Email
