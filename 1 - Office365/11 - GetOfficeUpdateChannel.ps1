[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$computerList = "C:\temp\computerList.csv"

$computers = Get-Content -Path $computerList

$myObjects = @()
foreach ($computer in $computers)
{
        $updateChannelName = ""
        $computerDescription = ""
        $officeVersion = ""
        $officeProduct = ""
        #Is the computer online?
        if ((Test-Connection -BufferSize 32 -Count 1 -ComputerName $computer -Quiet) -eq $true )
        {           

            $objReg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computer)
            $objRegKey= $objReg.OpenSubKey("SOFTWARE\\Microsoft\\Office\\ClickToRun\\Configuration")
            $updateChannel = $objRegkey.GetValue("UpdateChannel")

            $computerDescriptionRegKey = $objReg.OpenSubKey("SYSTEM\\CurrentControlSet\\Services\\LanmanServer\\Parameters")
            $computerDescription = $computerDescriptionRegKey.GetValue("srvcomment")

            #The Office 365 products, begin with the key O365.
            #We need to cycle the keys until we find a subkey that matches O365*
            #Then read that key, at that point break out of the for each as we have found what we were looking for
            $officeRegKey = $objReg.OpenSubKey("Software\\Microsoft\\Windows\\CurrentVersion\Uninstall\\")
            foreach($keyName in $officeRegKey.GetSubKeyNames())
            {
                if ($keyName -like "O365*")
                {
                    $officeRegKey = $objReg.OpenSubKey("Software\\Microsoft\\Windows\\CurrentVersion\Uninstall\\$keyName")
                    $officeProduct = $officeRegKey.GetValue("DisplayName")
                    $officeVersion = $officeRegKey.GetValue("DisplayVersion")
                    break
                }
            }
        
            switch ($updateChannel)
            {
                "http://officecdn.microsoft.com/pr/492350f6-3a01-4f97-b9c0-c7c6ddf67d60"
                {
                    $updateChannelName = "Monthly"
                    break
                }
                "http://officecdn.microsoft.com/pr/7ffbc6bf-bc32-4f92-8982-f9dd17fd3114"
                {
                    $updateChannelName = "Semi-Annual"
                    break
                }
                "http://officecdn.microsoft.com/pr/64256afe-f5d9-4f86-8936-8840a6a4f5be"
                {
                    $updateChannelName = "Monthly Channel (Targeted)"
                    break
                }
                "http://officecdn.microsoft.com/pr/b8f9b850-328d-4355-9145-c59439a0c4cf"
                {
                    $updateChannelName = "Semi-Annual Channel"
                    break
                }
                ""
                {
                    $updateChannelName = "Couldn't read 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Office\ClickToRun\Configuration\UpdateChannel'"
                    break
                }
            }

            $myObjects += [PSCustomObject]@{
                'Computer Name' = $computer
                'Computer Description' = $computerDescription
                'Office Product' = $officeProduct
                'Update Channel' = $updateChannelName        
                'Office Version' = $officeVersion
            }
        }
        else
        {
            $myObjects += [PSCustomObject]@{
                'Computer Name' = $computer
                'Computer Description' = "Not responding to ping"
                'Office Product' = "Not responding to ping"
                'Update Channel' = "Not responding to ping"        
                'Office Version' = "Not responding to ping"
            }
        } 
}

$exportPath = "C:\temp\OfficeUpdateChannels.csv"
$myObjects | Export-CSV -Path $exportPath -NoTypeInformation


