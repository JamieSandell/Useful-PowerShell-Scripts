function CreateIcons()
{
    $result = ""

    $result += CreateShortcutIfRequired `
	    "C:\Program Files (x86)\Google\Chrome\Application\" `
	    "C:\Program Files\Google\Chrome\Application\" `
	    "chrome.exe" `
	    "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
        "Google Chrome.lnk" `
	    "" `
	    ""
    $result += CreateShortcutIfRequired `
	    "C:\Program Files (x86)\Skype\Phone\" `
	    "C:\Program Files\Skype\Phone\" `
	    "Skype.exe" `
	    "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
        "Skype.lnk" `
	    "" `
	    ""
#For fresh skype installs via PDQ Deploy Skype for Desktop is installed in "C:\Program Files (x86)\Skype\Microsoft\Skype for Desktop"
#However, for legacy reasons, Skype 7.x and older was installed by default to "C:\Program Files (x86)\Skype\Phone\", so we need to check for both locations.
#Which is why we have this code below and above for Skype to cover all install locations.
#TODO Modify the script to allow an input of locations (array of strings) and check each one, will avoid multiple function calls for the same product.
    $result += CreateShortcutIfRequired `
	    "C:\Program Files (x86)\Microsoft\Skype for Desktop\" `
	    "" `
	    "Skype.exe" `
	    "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
        "Skype.lnk" `
	    "" `
	    ""
    $result += CreateShortcutIfRequired `
	    "C:\Program Files (x86)\Microsoft Office\root\Office16\" `
	    "C:\Program Files\Microsoft Office\root\Office16\" `
	    "lync.exe" `
	    "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
        "Skype for Business.lnk" `
	    "" `
	    ""
    $result += CreateShortcutIfRequired `
        "C:\Program Files (x86)\Microsoft Office\root\Office16\" `
	    "C:\Program Files\Microsoft Office\root\Office16\" `
        "Outlook.exe" `
        "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
        "Outlook 2016.lnk" `
        "" `
        ""
    $result += CreateShortcutIfRequired `
        "C:\Program Files (x86)\Microsoft Office\root\Office16\" `
	    "C:\Program Files\Microsoft Office\root\Office16\" `
        "WinWord.exe" `
        "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
        "Word 2016.lnk" `
        "" `
        ""
    $result += CreateShortcutIfRequired `
        "C:\Program Files (x86)\Microsoft Office\root\Office16\" `
	    "C:\Program Files\Microsoft Office\root\Office16\" `
        "Excel.exe" `
        "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
        "Excel 2016.lnk" `
        "" `
        ""
    $result += CreateShortcutIfRequired `
        "C:\Program Files (x86)\Microsoft Office\root\Office16\" `
	    "C:\Program Files\Microsoft Office\root\Office16\" `
        "Powerpnt.exe" `
        "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
        "PowerPoint 2016.lnk" `
        "" `
        ""
    $result += CreateShortcutIfRequired `
        "" `
	    "C:\sqlapps\LaunchPad2\" `
        "LaunchPad2.exe" `
        "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
        "Launchpad2.lnk" `
        "\\lan\netlogon\StartMenu\Icons\LaunchPad2.ico" `
        ""
    $result += CreateShortcutIfRequired `
        "" `
	    "C:\sqlapps\ContactsDB2\" `
        "GPCalculator.exe" `
        "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
        "GPCalculator.lnk" `
        "" `
        ""
    $result += CreateShortcutIfRequired `
        "c:\windows\system32\" `
	    "" `
        "SnippingTool.exe" `
        "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\Accessories\" `
        "Snipping Tool.lnk" `
        "" `
        ""

    $result += CreateShortcutIfRequired `
        "c:\windows\" `
	    "" `
        "explorer.exe" `
        "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
        "Shared Files.lnk" `
        "\\lan\netlogon\StartMenu\icons\Shared Files.ico" `
        "\\lan\files"
  
    $result += CreateShortcutIfRequired `
        "c:\windows\" `
	    "" `
        "explorer.exe" `
        "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
        "Explorer.lnk" `
        "" `
        ""

    $result += CreateShortcutIfRequired `
        "c:\windows\" `
	    "" `
        "explorer.exe" `
        "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
        "Documents.lnk" `
        "\\lan\netlogon\StartMenu\icons\Documents.ico" `
        "%userprofile%\OneDrive - Cyclops Electronics Ltd\Documents"

     $result += CreateShortcutIfRequired `
        "c:\windows\" `
	    "" `
        "explorer.exe" `
        "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
        "Downloads.lnk" `
        "\\lan\netlogon\StartMenu\icons\Downloads.ico" `
        "%userprofile%\OneDrive - Cyclops Electronics Ltd\Downloads"

    $result += CreateShortcutIfRequired `
        "c:\windows\" `
	    "" `
        "explorer.exe" `
        "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
        "Pictures.lnk" `
        "\\lan\netlogon\StartMenu\icons\Pictures.ico" `
        "%userprofile%\OneDrive - Cyclops Electronics Ltd\Pictures"

    $result += CreateShortcutIfRequired `
	    "C:\Program Files (x86)\Google\Chrome\Application\" `
	    "C:\Program Files\Google\Chrome\Application\" `
	    "chrome.exe" `
	    "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
        "ESS.lnk" `
	    "\\lan\netlogon\StartMenu\icons\ESS.ico" `
	    "https://ess.cyclops-electronics.com/ESS/"

    <#
	$result += CreateShortcutIfRequired `
		"\\lan\files\Datafile\PROGRAMS20\" `
		"" `
		"DFWIN.exe" `
		"$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
		"Datafile.lnk" `
		"\\lan\netlogon\StartMenu\Icons\DFWIN.ico" `
		"\\lan\files\Datafile"
	$result += CreateShortcutIfRequired `
		"" `
		"c:\windows\system32\" `
		"mstsc.exe" `
		"$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
		"i2i.lnk" `
		"C:\Program Files (x86)\RemotePackages\i2i.ico" `
		'"C:\Program Files (x86)\RemotePackages\i2i.RDP"'
	<# break
    #>
				
    
    $result += CreateShortcutIfRequired `
		"" `
		"C:\Program Files\Oracle\VirtualBox\" `
		"VirtualBox.exe" `
		"$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
		"Oracle VM VirtualBox.lnk" `
		"" `
		""

    #Gerbv installs itself in a sub dir of C:\Program Files\GraphiCode\ in the format GC-Prevue*, * being a wildcard for the version number.
    #So we need to call a function to determine the directory that GC-Prevue is installed in
    $error = ""
    $dirToSearch = "C:\Program Files\GraphiCode\"
    $filter = "GC-Prevue*"
    $dir = GetDirectory $dirToSearch $filter $error

    if (-not([string]::IsNullOrEmpty($error))) #We've received an error from the function
    {
        $result += "`r`n" + $error
    }
    elseif ([string]::IsNullOrEmpty($dir))
    {
        $result += "`r`n" + $dirToSearch + $filter + " was not found."
    }
    else
    {
        $result += CreateShortcutIfRequired `
		"" `
		$dir `
		"gcprevue.exe" `
		"$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
		"GC-Prevue.lnk" `
		"" `
		""
    }
    #GC-Prevue installs itself in a sub dir of C:\Program Files (x86)\gerbv-*\bin\, * being a wildcard for the version number.
    #So we need to call a function to determine the directory that Gerbv is installed in
    $error = ""
    $dirToSearch = "C:\Program Files (x86)\gerbv-*\"
    $filter = "bin"
    $dir = GetDirectory $dirToSearch $filter $error

    if (-not([string]::IsNullOrEmpty($error))) #We've received an error from the function
    {
        $result += "`r`n" + $error
    }
    elseif ([string]::IsNullOrEmpty($dir))
    {
        $result += "`r`n" + $dirToSearch + $filter + " was not found."
    }
    else
    {
        $result += CreateShortcutIfRequired `
		"" `
		$dir `
		"gerbv.exe" `
		"$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
		"gerbv.lnk" `
		"" `
		""
    }
                
    $result += CreateShortcutIfRequired `
		"" `
		"c:\windows\system32\" `
		"mstsc.exe" `
		"$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
		"i2i Hosted.lnk" `
		"C:\Program Files (x86)\RemotePackages\i2i.ico" `
		'"C:\Program Files (x86)\RemotePackages\i2i.RDP"'

    #The shortcut created for Sirrom is dependant on the subnet of the user's PC.
    #If the user is in York they'll get a shortcut based that points to a locally installed app.
    #If the user is in Hull they'll get a shortcut that points to a remote app
    $ipAddresses = (Get-NetIPAddress).IPAddress
    foreach ($ipAddress in $ipAddresses)
    {
        switch -Wildcard ($ipAddress)
        {
            '172.23.146*' #York subnet
            {
                $result += CreateShortcutIfRequired `
					"C:\Program Files (x86)\Autotime Systems\Sirrom\" `
					"C:\Program Files\Autotime Systems\Sirrom\" `
					"Sirrom.exe" `
					"$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
					"Sirrom.lnk" `
					"\\lan\netlogon\StartMenu\Icons\Sirrom.ico" `
					""
                $result += CreateShortcutIfRequired `
		                "\\lan\files\Datafile\PROGRAMS20\" `
		                "" `
		                "DFWIN.exe" `
		                "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
		                "Datafile.lnk" `
		                "\\lan\netlogon\StartMenu\Icons\DFWIN.ico" `
		                "\\lan\files\Datafile"
            }
        
            '172.23.152*' #Hull subnet
            {
                $result += CreateShortcutIfRequired `
					"C:\Windows\System32\" `
					"" `
					"mstsc.exe" `
					"$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
					"Sirrom.lnk" `
					"C:\Program Files (x86)\RemotePackages\Autotime Systems\Sirrom\sirrom.ico" `
					'"C:\Program Files (x86)\RemotePackages\Autotime Systems\Sirrom\sirrom.rdp"'

                $result += CreateShortcutIfRequired `
					"C:\Windows\System32\" `
					"" `
					"mstsc.exe" `
					"$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
					"Datafile.lnk" `
					"C:\Program Files (x86)\RemotePackages\Datafile Software Solutions\Datafile\Datafile.ico" `
					'"C:\Program Files (x86)\RemotePackages\Datafile Software Solutions\Datafile\Datafile.rdp"'
            }
        }
    }

	$result += CreateShortcutIfRequired `
		"" `
		"C:\Program Files\Adobe\Adobe InDesign CC 2017\" `
		"InDesign.exe" `
		"$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
		"Adobe InDesign CC 2017.lnk" `
		"" `
		""
	$result += CreateShortcutIfRequired `
		"" `
		"C:\Program Files\Adobe\Adobe Photoshop CC 2017\" `
		"Photoshop.exe" `
		"$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
		"Adobe Photoshop CC 2017.lnk" `
		"" `
		""
	$result += CreateShortcutIfRequired `
		"C:\Program Files (x86)\Adobe\Adobe Creative Cloud\ACC\" `
		"" `
		"Creative Cloud.exe" `
		"$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
		"Adobe Creative Cloud.lnk" `
		"" `
		""

    $result += CreateShortcutIfRequired `
		"C:\Program Files (x86)\KeePass Password Safe 2\" `
		"" `
		"KeePass.exe" `
		"$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
		"KeePass.lnk" `
		"" `
		""

    return $result
}


#Creates a shortcut and returns a string as the result
#
#Example:
#CreateShortcut "%programdata%\Microsoft\Windows\Start Menu\Programs\i2i.lnk"
#				"C:\Program Files (x86)\RemotePackages\i2i.rdp"
#				"C:\Program Files (x86)\RemotePackages"
#				"C:\Program Files (x86)\RemotePackages\i2i.ico"
#				""
function CreateShortcut ([string]$shortcutPathAndName, [string]$targetPath, [string]$workingDir, [string]$iconLocation,	[string]$arguments)
{
    $Shell = New-Object -ComObject ("WScript.Shell")

    $Shortcut = $Shell.CreateShortcut($shortcutPathAndName)
	$result += "`r`nShortcut Path and Name = " + $shortcutPathAndName
	
    $Shortcut.TargetPath = $targetPath
	$result += "`r`nTargeth Path = " + $Shortcut.TargetPath
	
    $Shortcut.WorkingDirectory = $workingDir
	$result += "`r`n Working Dir = " + $Shortcut.WorkingDirectory
	
    $Shortcut.IconLocation = $iconLocation
	$result += "`r`n Icon Location = " + $Shortcut.IconLocation
	
	$Shortcut.Arguments = $arguments
	$result += "`r`n Arguments = " + $Shortcut.Arguments
	
    $Shortcut.Save()

    $result += "`r`nShortcut created in " + $shortcutPathAndName + " pointing to " + $targetPath
	return $result
}

#Example:
#CreateShortcutIfRequired "C:\Program Files (x86)\RemotePackages\"
#							""
#							"i2i.rdp"
#							"C:\programdata\Microsoft\Windows\Start Menu\Programs\"
#							"i2i.lnk"
#							"" #Empty string means that we will use the targetFile icon as the icon.
#							"" #Empty string means no arguments
function CreateShortcutIfRequired([string]$32bitPath, [string]$64bitPath, [string]$targetFile, [string]$shortcutDir, [string]$shortcutName, [string]$iconLocation, [string]$arguments)
{
	$result = ""
	$shortcut = $shortcutDir + $shortcutName
	$result += "`r`nThe shortcut to create is " + $shortcut


    #Does the directory exist where we want to create the shortcut, if not create it?
    if (-not (Test-Path $shortcutDir))
    {
        $result += "`r`nThe shortcut directory " + $shortcutDir + " does not exist."
        New-Item -ItemType directory -Path $shortcutDir
        $result += "`r`nDirectory " + $shortcutDir + " created."
    }
	
	if ((Test-Path ($32bitPath + $targetFile)) -And (Test-Path ($64bitPath + $targetFile)))
	{
		if (($32bitPath -ne "") -And ($64bitPath -ne "")) #if passed in a 64-bit and 32-bit path not just an empty string
		{
			#The target is in the 32 bit path and 64-bit path, write to the log file and exit
			$result +=  "`r`nboth " + $32bitPath + $targetFile + " and " + $64bitPath + $targetFile + " exist."
			$result += "`r`nTaking no action as which is the correct target for the shortcut?"
			return $result
		}		
	}

	#if (-not (Test-Path $shortcut)) #if the shortcut doesn't exist then create it
	#{		
		$result += "`r`nThe shortcut " + $shortcut + " is not present."

		if (Test-Path ($32bitPath + $targetFile)) #Create the shortcut to point to "Program Files (x86)" as the program is installed there
		{    
			$result += "`r`n" + $32bitPath + $targetFile + " exists."
			
			$targetPath = $32bitPath + $targetFile			
			$result += "`r`nThe target path of the shortcut to create is " + $targetPath
			
			if ($iconLocation -eq "") #If the passed in iconLocation is an empty string, then use the target file's icon
			{
				$iconLocation = $32bitPath + $targetFile + " ,0"
			}
			
			$result += "`r`nCalling CreateShortcut"
			$result += CreateShortcut $shortcut $targetPath $32bitPath $iconLocation $arguments			
			$result += "`r`nReturned from calling CreateShortcut"
			$result += "`r`nIcon Location = " + $iconLocation
		}
		elseif (Test-Path ($64bitPath + $targetFile)) #Create the shortcut to point to "Program Files" as the program is installed there
		{    
			$result += "`r`n" + $64bitPath + $targetFile + " exists."
			
			$targetPath = $64bitPath + $targetFile			
			$result += "`r`nThe target path of the shortcut to create is " + $targetPath
			
			if ($iconLocation -eq "") #If the passed in iconLocation is an empty string, then use the target file's icon
			{
				$iconLocation = $64bitPath + $targetFile + " ,0"
			}
			
			$result += "`r`nCalling CreateShortcut"
			$result += CreateShortcut $shortcut $targetPath $64bitPath $iconLocation $arguments			
			$result += "`r`nReturned from calling CreateShortcut"
			$result += "`r`nIcon Location = " + $iconLocation
		}
		else #The program isn't installed, or is not installed where we expect it to be
		{
			$result += "`r`n" + $32bitPath + $targetFile + " or " + $64bitPath + $targetFile + " is not present."
		}
		
		return $result
	#}
    else
    {
        $result += "`r`n The shortcut " + $shortcut + " already exists"
        return $result
    }    
}

#$dir = the directory to search for
#$filter = the filter, e.g. wildcards
#$errror = Populated by the function. Empty string if no errors, otherwise contains any error messages
#Function returns a string, the string is empty if not successful, otherwise it contains the directory
#Example:
#Search for a folder beginning with GC-Prevue in C:\Program Files\GraphiCode\
#GetDirectory "C:\Program Files\GraphiCode\" "GC-Prevue*" ""
function GetDirectory($dir, $filter, $error)
{
    $result = ""
    $error = ""

    if (-not(Test-Path $dir))
    {
        #Directory to search does not exist
        $error = "The directory does not exist"
        return $error
    }
    else
    {
        $dir = Resolve-Path $dir | Select -ExpandProperty Path #in case the path passed in contains wildcards, we need to resolve the actual directory.
        $childItem = Get-ChildItem -Path $dir -Recurse -Directory -Filter $filter
        $childItem = $childItem.Name

        $result = $dir + "\" + $childItem

        #Potentially the result will not contain a trailing \. If it doesn't we need to add it.
        $lastIndexOf = $result.LastIndexOf('\')
        if ($lastIndexOf -ne ($result.Length - 1))
        {
            $result = $result + "\"
        }

        return $result
    }    
    
}

#region Logging
$date = Get-Date
$logPath = "\\lan\files\Public\IT\Logs\CreateStartMenuShortcuts\Base\$env:ComputerName"
$logFile = "$($date.Day)-$($date.Month)-$($date.Year)-$($date.Hour)-$($date.Minute)-$($date.Second)-$env:ComputerName.txt"
$ErrorActionPreference = "SilentlyContinue"
try {stop-transcript | out-null} catch {}
$ErrorActionPreference = "Continue"
Start-Transcript -path ($logPath+"\"+$logFile) -Append
#endregion

CreateIcons

#End logging
Stop-Transcript