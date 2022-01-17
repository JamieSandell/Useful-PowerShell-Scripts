import-module '..\powershell modules\logging.psm1'
$logFile = '.\'
$logFile += $env:computername+" "+$(get-date -f dd-MM-yyyy-HH-mm)+".txt"

Start-Logging -logFile $logFile

$userConfigSource = "$env:LOCALAPPDATA\Microsoft_Corporation\servermanager.exe_StrongName_m3xk0k0ucj0oj3ai2hibnhnv4xobnimj\10.0.0.0\user.config"
$userConfigBackup = "SharedLocation\PreviousVersions\user.config.$(get-date -f dd.MM.yyyy)"
$userConfigDestination = 'SharedLocation\ServerManager\user.config'
#Back up the current user config
Copy-Item $userConfigDestination -Destination $userConfigBackup
Log-Info "Backed up $userConfigDestination to $userConfigBackup"
#Update the current user config
Copy-Item $userConfigSource -Destination $userConfigDestination
Log-Info "Copied $userConfigSource to $userConfigDestination"


$serverListSource = "$env:APPDATA\Microsoft\Windows\ServerManager\ServerList.xml"
$serverListBackup = "\\SharedLocation\PreviousVersions\ServerList.xml.$(get-date -f dd.MM.yyyy)"
$serverListDestination = '\\SharedLocation\ServerManager\ServerList.xml'
#Back up the current server list
Copy-Item $serverListDestination -Destination $serverListBackup
Log-Info "Backed up $serverListDestination to $serverListBackup"
#Update the current server list
Copy-Item $serverListSource -Destination $serverListDestination
Log-Info "Copied $serverListSource to $serverListDestination"

Stop-Logging