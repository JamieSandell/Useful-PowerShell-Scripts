<#
Example:
Delete-Folder c:\test
This would delete the folder c:\test on the local computer

Example:
Delete-Folder c:\test PC01
This would delete the folder c:\test on the computer PC01

Example:
Import-Csv 'C:\Temp\BackupFoldersFound.csv' |`
    ForEach-Object {
        $FullName += $_.FullName
        $PSComputerName += $_.PSComputerName

        Delete-Folder $_.FullName $_.PSComputerName
    }

This reads a CSV file with two columns, FullName and PSComputerName.
FullName = The directory to delete
PSComptuerName = The name of the computer

It then goes line by line deleting the folder specified from the corresponding computer.
#>

Function Delete-Folder
{
    Param(
        [Parameter(Mandatory=$true)]
        [string[]]$folder,
        [string]$computerName = $env:COMPUTERNAME
    )

    $scriptBlock = {
        param($folder)
        Remove-Item -Path $folder -Recurse -Force        
    }
    if ($computerName -eq $env:COMPUTERNAME)
    {
        return Invoke-Command -scriptblock $scriptBlock
    }
    else
    {
        return Invoke-Command -ComputerName $computerName -scriptblock $scriptBlock -ArgumentList $folder
    }
    
}