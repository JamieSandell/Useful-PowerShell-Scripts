Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-PackageProvider nuget
If(-not(Get-InstalledModule GetFirmwareBIOSOrUEFI -ErrorAction silentlycontinue))
{
    Set-PSRepository PSGallery -InstallationPolicy Trusted
    Install-Module GetFirmwareBIOSOrUEFI -Confirm:$False -Force
}

Function Get-BIOSType
{
    Write-Output ((Get-FirmwareType).firmwaretype)
}

Function Write-BIOSTypeToRegistry
{
    $path = 'HKLM:\HARDWARE\BIOS'
    $name = 'Type'
    $value = Get-BIOSType

    if ((Test-Path -Path $path) -eq $false)
    {
        New-Item -Path $path | Out-Null
    }
    New-ItemProperty -Path $path -Name $name -Value $value -Force | Out-Null
}

Write-BIOSTypeToRegistry