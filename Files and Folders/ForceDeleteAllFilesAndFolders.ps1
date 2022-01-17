Get-ChildItem 'D:\$RECYCLE.BIN' -recurse -force | ? { $_.PSIsContainer -ne $true } | % {Remove-Item -Path $_.FullName -Force }
Remove-Item 'D:\$RECYCLE.BIN' -Recurse -Force