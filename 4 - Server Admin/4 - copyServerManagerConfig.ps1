$logFileDir = ".\"
$logFileName = $env:computername+" "+$(get-date -f dd-MM-yyyy-HH-mm)+".txt"
$logFile = $logFileDir + $logFileName

$userConfigFile = New-Object -TypeName PSObject
$userConfigFile | Add-Member -MemberType NoteProperty -Name Source -Value ".\ServerManager\"
$userConfigFile | Add-Member -MemberType NoteProperty -Name Destination -Value ($env:LOCALAPPDATA + "\Microsoft_Corporation\servermanager.exe_StrongName_m3xk0k0ucj0oj3ai2hibnhnv4xobnimj\10.0.0.0\")
$userConfigFile | Add-Member -MemberType NoteProperty -Name Name -Value "user.config"

$serverListFile = New-Object -TypeName PSObject
$serverListFile | Add-Member -MemberType NoteProperty -Name Source -Value ".\ServerManager\"
$serverListFile | Add-Member -MemberType NoteProperty -Name Destination -Value ($env:APPDATA + "\Microsoft\Windows\ServerManager\")
$serverListFile | Add-Member -MemberType NoteProperty -Name Name -Value "ServerList.xml"

$files = @($userConfigFile, $serverListFile)

foreach ($file in $files)
{
    if (Test-Path $file.Destination)
    {
        $log += "The destination: " + $file.Destination + " exists.`r`n"
        #does the file exist?
        if (Test-Path ($file.Destination+$file.Name))
        {
            $log += "The file: " + $file.Name + " does exist in " + $file.Destination + "`r`n"
        }
        else
        {
            $log += "The file: " + $file.Name + " does not exist in " + $file.Destination + "`r`n"
        }

        Copy-Item -Path ($file.Source+$file.Name) -Destination ($file.Destination+$file.Name)
        $log += "The file: " + $file.Name + " in " + $file.Source + "has been copied to " + $file.Destination + "`r`n"    
    }
    else
    {
        $log += "The destination: " + $file.Destination + " does not exist.\r\n"
    }
}

$log | Out-File $logFile