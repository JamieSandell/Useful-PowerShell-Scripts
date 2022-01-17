#Removes all RDP connections from the registry. (The last 10 are stored)
Remove-Item -Path "HKCU:\Software\Microsoft\Terminal Server Client\Default" -Recurse
Remove-Item -Path "HKCU:\Software\Microsoft\Terminal Server Client\Servers" -Recurse


#Removes the i2i.ico and i2i.rdp hives from the registry.
Remove-Item -Path "HKCU:\Software\Microsoft\Terminal Server Client\RemoteApplications\*" -Recurse
Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" -Recurse

Exit