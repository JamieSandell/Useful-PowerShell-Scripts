Import-Module -Name '..\powershell modules\Email.psm1'

$MonitorFolder = "D:\HelpDesk"
$MonitFolderUNC = "\\HelpDesk"
$MonitorStopFile = "end.Mon"
$smtpFrom = "helpdesk@contoso.com"  
$smtpTo = "helpdesk@contoso.com" 
$smtpSubject = "New file added in $($MonitorFolder)." 
 
$SourceID = "MonitorFiles" 
$Query = @" 
SELECT * FROM __InstanceCreationEvent WITHIN 10 
WHERE targetInstance ISA 'Win32_SubDirectory' 
AND targetInstance.GroupComponent = 'Win32_Directory.Name="$($MonitorFolder.Replace("\", "\\\\"))"' 
"@ 
Try { 
    $smtp = New-Object -TypeName "Net.Mail.SmtpClient" -ArgumentList $smtpServer 
    Register-WmiEvent -Query $Query -SourceIdentifier $SourceID 
    Do { 
        "Waiting for a new file to arrive in '$($MonitorFolder)'; to stop, hit <Ctrl-C> or create a file '$MonitorStopFile'." | Write-Host 
        $FileEvent = Wait-Event -SourceIdentifier $SourceID 
        Remove-Event -EventIdentifier $FileEvent.EventIdentifier 
        $FileName = $FileEvent.SourceEventArgs.NewEvent.TargetInstance.PartComponent.Split("=", 2)[1].Trim('"').Replace("\\", "\") 
        If ((Split-Path -Path $FileName -Leaf) -eq $MonitorStopFile) { 
            $smtpBody = "[$(Get-Date -Format HH:mm:ss)]`tStop file arrived: '$($FileName)'; monitor is going down!" 
            Remove-Item -Path (Join-Path -Path $MonitorFolder -ChildPath $MonitorStopFile) 
            $FileEvent = $Null 
        } Else { 
            $smtpBody = "[$(Get-Date -Format HH:mm:ss)]`tNew folder arrived: '$($FileName)'
            UNC folder = '$($MonitFolderUNC)'" 
             
        } 
        $smtpBody | Write-Host -Fore Yellow 
        Send-MailMessage -To $smtpTo -From $smtpFrom -Subject $smtpSubject -Body $smtpBody 
    } While ($FileEvent) 
} Catch { 
    $_ | Out-String | Write-Error 
} Finally { 
    Remove-Event -SourceIdentifier $SourceID -ErrorAction SilentlyContinue 
    Unregister-Event -SourceIdentifier $SourceID -ErrorAction SilentlyContinue 
}

Remove-Module -Name Email