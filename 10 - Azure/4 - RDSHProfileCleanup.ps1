$regKeysToDelete = @{
    'HKLM:\1' = 'joebloggsWindowsProfile'
    'HKLM:\2' = 'jonnyroseWindowsProfile'
}

foreach ($key in $regKeysToDelete.Keys)
{
    Remove-ItemProperty -Path $key -Name $regKeysToDelete.$key
}

$foldersToDelete = 'c:\users\joe.bloggs', 'c:\users\jonny.rose'
foreach ($folder in $foldersToDelete)
{
    Remove-Item -Recurse -Force $folder
}