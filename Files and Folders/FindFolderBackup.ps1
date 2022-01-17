. ".\GetFolders.ps1" #Load the GetFolders script so we can call the Get-Folders function

$baseDir = "c:\users\*\OneDrive*" #directory to search, can use wildcards, will search all subdirectories recursively
$nameToFind = "Backup" #the name of the folder to look for

$machines = Get-Content -Path '.\FindFolderBackupMachines.txt' #read in a name of computers to search
$offlineMachines = @() #used for storing offline PCs from the list if you need to keep a record of them
$result = @() #stores all the scan results that match

foreach ($machine in $machines) #loop through the list of computers read in from the txt file
{
    if (Test-Connection $machine -Quiet -Count 1) #is the PC online?
    {
        Write-Output $machine + " is online, getting folders`r`n"
        $temp = Get-Folders $baseDir $nameToFind $machine
        if ($temp) #did we find a backup folder?
        {
            $result += $temp
        }
    }
    else
    {
        Write-Output $machine + " is offline`r`n"
        $offlineMachines += $machine
    }
}

Write-Output $offlineMachines

$csvLines = @() #build the CSV file and stores the results.
foreach ($entry in $result)
{
    $object = New-Object -TypeName PSObject -Property @{
        PSComputerName = $entry.PSComputerName
        FullName = $entry.FullName
    }
    $csvLines += $object
}

$savePath = "C:\temp\"
$saveFile = "BackupFoldersFound.csv"
$outFile = $savePath + $saveFile

$csvLines | Export-Csv $outFile -NoTypeInformation #Output our logon and logoff events to a CSV file.
