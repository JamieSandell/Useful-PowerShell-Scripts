function Log-Info
{
    [CmdletBinding()]
    Param
    (
        [parameter(Mandatory=$true, Position=0)]
        $logInfo
    )
    
    Write-Host ("{1} - {0} - {2}" -f (Get-Date), "INFO", $logInfo)
    
}

function Log-Error
{
    [CmdletBinding()]
    Param
    (
        [parameter(Mandatory=$true, Position=0)]
        $logError
    )

    Write-Host ("{1} - {0} - {2}" -f (Get-Date), "ERROR", $logError)
}

function Log-Warning
{
    [CmdletBinding()]
    Param
    (
        [parameter(Mandatory=$true, Position=0)]
        $logError
    )

    Write-Host ("{1} - {0} - {2}" -f (Get-Date), "WARNING", $logError)    
}

[string] $logFile
function Get-LogFile
{
    return $Script:logFile
}

function Start-Logging
{
    Param(
        [Parameter(Mandatory=$false)][string] $logFile
    )

    #Start logging the transcript to a file
    try
    {
        Stop-Transcript | Out-Null
    }
    catch
    {
    }
    $ErrorActionPreference = "Continue"
    $Script:logFile = $Local:logFile
    Start-Transcript -path ($logFile)
}

function Stop-Logging
{
    Stop-Transcript
}

#Declare which functions to export/make available
Export-ModuleMember -Function 'Get-LogFile'
Export-ModuleMember -Function 'Log-Info'
Export-ModuleMember -Function 'Log-Warning'
Export-ModuleMember -Function 'Log-Error'
Export-ModuleMember -Function 'Start-Logging'
Export-ModuleMember -Function 'Stop-Logging'