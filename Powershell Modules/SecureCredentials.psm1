<#
.Synopsis
    Encrypts a password to a txt file

.Description
    Encrypts a password to a txt file.
    If no filePath is specified it will output to '\\lan\files\IT\Cyclops\York\Powershell Scripts\Credentials\$env:COMPUTERNAME\$env:USERNAME\$description.txt'
    If a filePath is specified the output will be '$filePath\$env:COMPUTERNAME\$env:USERNAME\$description.txt'

.Parameter filePath
    Optional - String - filePath to store the encrypted key

.Example
    Set-SecureCredentials

.Example
    Set-SecureCredentials '\\lan\files\Documents\jamies'

.Link
    https://mcpmag.com/articles/2017/07/20/save-and-read-sensitive-data-with-powershell.aspx
#>
Function Set-SecureCredentials
{
    Param(
        [Parameter(Mandatory=$false)][string] $filePath = '\\lan\files\IT\Cyclops\York\Powershell Scripts\Credentials'
    )

    #$password = Read-Host "Password`t" -AsSecureString
    $description = Read-Host "Description`t"

    if ($filePath -eq '\\lan\files\IT\Cyclops\York\Powershell Scripts\Credentials')
    {
        $filePath += "\$env:COMPUTERNAME\$env:USERNAME\$description.xml"
    }
    else
    {
        $filePath += "\$description.xml"
    }
    
    New-Item -Path $filePath -ItemType "file" -Force
    Get-Credential | Export-Clixml -Path $filePath

}

Function Get-SecureCredentials
{
    Param(
        [Parameter(Mandatory=$true)][string] $file
    )

    $credentials = Import-Clixml -Path $file
    Write-Output $credentials

}

#Declare which functions to export/make available
Export-ModuleMember -Function 'Set-SecureCredentials'
Export-ModuleMember -Function 'Get-SecureCredentials'