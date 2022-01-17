<#
Start logging
Close the process
End logging
#>

param(
    [Parameter(Mandatory=$true)][string]$process
)

$logFileDir = ".\$env:USERNAME"
$logFileName = "$(Get-Date -format "dd-MM-yyyy-HH-mm-ss").log"

Import-Module '\\lan\netlogon\Scripts\Powershell Modules\Logging.psm1'
Start-Logging -logFile $logFileDir\$logFileName

Log-Info "Finding processes that match *$($process)*"
$processes = $null
$processes = Get-Process -Name "$process"

if ($processes -eq $null)
{
    Log-Info "No processes found matching $process, no action to take"
}
else
{   
    Log-Info "Found processes matching *$process*"
    Log-Info "Attempting to gracefully close theses processes, will forcibly close any that fail to gracefully close."
    Get-Process -Name "$process" | Foreach-Object {$_.CloseMainWindow() | Out-Null} | Stop-Process -Force

    Get-Process -Name $process | Stop-Process -Force -ErrorAction SilentlyContinue
}

Stop-Logging