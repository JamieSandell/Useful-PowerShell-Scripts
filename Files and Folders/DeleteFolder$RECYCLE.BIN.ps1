. ".\DeleteFolder.ps1" #Load the DeleteFolder script so we can call the Delete-Folder function

Import-Csv 'C:\Temp\$RECYCLE.BINFoldersFound.csv' |`
    ForEach-Object {
        Delete-Folder $_.FullName $_.PSComputerName
    }


