. ".\DeleteFolder.ps1" #Load the DeleteFolder script so we can call the Delete-Folder function

$CSVContent = Get-Content -Path 'C:\Temp\BackupFoldersFound.csv'

$FullName = @()
$PSComputerName = @()

Import-Csv 'C:\Temp\BackupFoldersFound.csv' |`
    ForEach-Object {
        $FullName += $_.FullName
        $PSComputerName += $_.PSComputerName

        Delete-Folder $_.FullName $_.PSComputerName
    }


