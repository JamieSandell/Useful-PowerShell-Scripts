<#
With roaming profiles, when a user first logs on their profile is created on the server (\\LAN\Users\Profiles).
This is locked down to SYSTEM and $env:Username. Meaning administrators don't have access to it.

To fix this this script can be placed in RunOnce under HKCU via a GPO.
Alternatively this script can be ran as the user. This is because the user has ownership of their roaming profile directory so they can edit the permissions.
No need for elevated privilages.
#>


Import-Module '..\Powershell Modules\Logging.psm1'

$date = Get-Date
$logPath = ".\$env:username"
$logFile = "$($date.Day)-$($date.Month)-$($date.Year)-$env:ComputerName.txt"

#Start logging the transcript to a file
Start-Logging -logFile ($logPath+"\"+$logFile)

$ErrorActionPreference = "Continue"
icacls $env:AppData /grant --% Administrators:(OI)(CI)F /T

#Finish logging the transcript to a file
Stop-Logging