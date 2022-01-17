#region Functions
function Log-Info
{
    [CmdletBinding()]
    Param
    (
        [parameter(Mandatory=$true, Position=0)]
        [String]$logInfo
    )

    Write-Output ("{1} - {0} - {2}" -f (Get-Date), "INFO", $logInfo)
}

function Log-Error
{
    [CmdletBinding()]
    Param
    (
        [parameter(Mandatory=$true, Position=0)]
        [String]$logError
    )

    Write-Output ("{1} - {0} - {2}" -f (Get-Date), "ERROR", $logError)
}

function Log-Warning
{
    [CmdletBinding()]
    Param
    (
        [parameter(Mandatory=$true, Position=0)]
        [String]$logError
    )

    Write-Output ("{1} - {0} - {2}" -f (Get-Date), "WARNING", $logError)    
}
#endregion
$date = Get-Date
$logPath = ".\$env:username"
$logFile = "$($date.Day)-$($date.Month)-$($date.Year)-$env:ComputerName.txt"
$skypeUpdatePath = "$env:AppData\Microsoft\Skype for Desktop\"
$skypeUpdateFile = "Skype-Setup.exe"

Start-Transcript -path ($logPath+"\"+$logFile)

if (Test-Path ($skypeUpdatePath+$skypeUpdateFile)) #does the item exist
{
    Log-Info "$skypeUpdatePath+$skypeUpdateFile exists."
    Remove-Item -Path ($skypeUpdatePath+$skypeUpdateFile) -Force #remove the item
    Log-Info "$skypeUpdatePath+$skypeUpdateFile removed."
    #if the item was a file it is removed, to stop it being created again by Skype, create a directory of the same name as the file
    New-Item -Path $skypeUpdatePath -ItemType "directory" -Name $skypeUpdateFile -Force
    Log-Info "$skypeUpdatePath+$skypeUpdateFile directory created."
}
else
{
    Log-Info "$skypeUpdatePath+$skypeUpdateFile doesn't exist."
    New-Item -Path $skypeUpdatePath -ItemType "directory" -Name $skypeUpdateFile -Force
    Log-Info "$skypeUpdatePath+$skypeUpdateFile directory created."
}

Stop-Transcript