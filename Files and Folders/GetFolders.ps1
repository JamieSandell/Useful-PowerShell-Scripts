<#
Example:
$result = Get-Folders "c:\users\*\OneDrive*" "Backup"

This would return a string array of all folders in c:\users\*\Onedrive that contain a folder called Backup.
This searches recursively, and * is a wildcard. Meaning if there were two users on the PC, JamieS and RonnieF then it would search both:
c:\users\JamieS\OneDrive and c:\users\RonnieF\OneDrive for all folders called Backup

Example:
. ".\GetFolders.ps1" #Load the GetFolders script so we can call the Get-Folders function

$baseDir = "c:\users\*\OneDrive*" #directory to search, can use wildcards, will search all subdirectories recursively
$nameToFind = "Backup" #the name of the folder to look for

$machines = Get-Content -Path '\\.\FindFolderBackupMachines.txt' #read in a name of computers to search
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

#>

Function Get-Folders
{
    Param(
        [Parameter(Mandatory=$true)]
        [string[]]$baseDir,
        [Parameter(Mandatory=$true)]
        [string]$nameToFind,
        [string]$computerName = $env:COMPUTERNAME
    )

    $scriptBlock = {
        param($baseDir, $nameToFind)
        $result = Get-ChildItem $baseDir -Recurse | Where-Object { $_.PSIsContainer -and $_.Name.Equals($nameToFind)}
        Write-Output $result #Have to do this to return the $result from the script block.
    }
    if ($computerName -eq $env:COMPUTERNAME)
    {
        return Invoke-Command -scriptblock $scriptBlock
    }
    else
    {
        return Invoke-Command -ComputerName $computerName -scriptblock $scriptBlock -ArgumentList $baseDir, $nameToFind
    }
    
}