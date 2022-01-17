import-module NTFSSecurity

$a = Get-Content "C:\Temp\TakeOwnership.txt"
foreach ($i in $a)
{
    if(test-path $i)
  {
        write-host Taking ownership of Directory $i -fore Green 
        get-item $i | SET-NTFSOwner -Account 'LAN\Domain Admins'
        get-item $i | Add-NTFSAccess -account 'BUILTIN\Administrators' -AccessRights FullControl
        get-item $i | Add-NTFSAccess -Account 'NT AUTHORITY\System' -AccessRights FullControl
        get-item $i | Add-NTFSAccess -Account 'LAN\jamies' -AccessRights FullControl
 
        $items = @()
        $items = $null
        $path = $null
        $items = get-childitem $i -recurse -force
        foreach($item in $items)
            {
                $path = $item.FullName
                Write-Host ...Adding AdminGroup to $path -Fore Green
                Get-Item -force $path | SET-NTFSOwner -Account 'LAN\Domain Admins'
                Get-Item -force $path | Add-NTFSAccess -Account 'BUILTIN\Administrators' -AccessRights FullControl
            }
   }
}