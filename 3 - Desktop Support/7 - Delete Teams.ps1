Import-Module '..\Powershell Modules\Logging.psm1'
Start-Logging -logFile ".\$(Get-Date -Format FileDate)-$env:USERNAME.log"

$foldersToDelete = @(
    ("$env:LOCALAPPDATA\Microsoft\Teams"),
    ("$env:APPDATA\Microsoft\Teams")
)

foreach($folder in $foldersToDelete)
{
    if ((Test-Path -LiteralPath $folder) -eq $true)
    {
        Remove-Item $folder -Force -Recurse -ErrorAction SilentlyContinue
        Log-Info "Deleted $folder."
    }
    else
    {
        Log-Info "$folder not found."
    }    
}

$keyPath = 'HKCU:\Software\Microsoft\Office\Teams'
$propertyToDelete = 'PreventInstallationFromMsi'
if ((Test-Path -LiteralPath $keyPath) -eq $true)
{
    Log-Info "$keyPath found."
    $valueNames = (Get-Item -LiteralPath $keyPath).Property -like $propertyToDelete
    if ($valueNames)
    {
        Remove-ItemProperty -Path $keyPath -Name $propertyToDelete
        Log-Info "$keyPath\$propertyToDelete deleted."
    }
    else
    {
        Log-Info "$keyPath\$propertyToDelete not found."
    }
}

Stop-Logging