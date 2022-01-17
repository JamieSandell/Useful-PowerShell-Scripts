<#
If a user get's the "Can't sign in to Skype for Business" and the body of the error message reads:
"Skype for Business can't sign in. You might not
have the permissions needed for Skype for Business
to access the Windows file system, or there might
be a problem with your installation of Office"

then it's likely they have a file called Office in $env:localappdata\Microsoft
A fix for this is to delete this file and create a folder of the same name in the same location

1. Start logging
2. If Office doesn't exist, create the folder
3. Elseif office is a file type, then delete it and create the folder
4. Else nothing to do
5. Stop logging
#>

#region Start Logging
Import-Module '..\powershell modules\Logging.psm1'

$logFileDirectory = ".\$env:username"
#Create the logfile directory if it doesn't exist
if ((Test-Path $logFileDirectory -PathType Container) -eq $false) {
    New-Item -ItemType Directory -Force -Path $logFileDirectory
}

#Generate the log file name
$date = (Get-Date).ToString('dd_MM_yyyy')
$time = (Get-Date).ToString('HH_mm_ss')
$computerName = $env:COMPUTERNAME
$logFileName = $date+'_'+$time+'_'+$computerName

Start-Logging -logFile "$logFileDirectory\$logFileName.log"
#endregion

#region Create the Office Folder
$office = "$env:localappdata\Microsoft\Office"

#Create the office directory if it doesn't exist
if ((Test-Path $office -PathType Any) -eq $false)
{
    Log-Info "The item $office does not exist"
    New-Item -ItemType Directory -Force -Path $office
    Log-Info "Created the folder $office"
}
else
{
    if ((Test-Path $office -PathType Leaf) -eq $true)
    {
        Log-Info "The item $office exists and is a file"
        Remove-Item -Path $office -Force
        Log-Info "Removed $office"
        New-Item -ItemType Directory -Force -Path $office
        Log-Info "Created the folder $office"
    }
    else #If at this point, then it's safe to say that $office already existed and is a directory
    {
        Log-Info "The item $office already exists and is a directory"
    }
}
#endregion

#region Stop Logging
Stop-Logging
#endregion