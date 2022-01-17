function CreateIcons()
{
    $result = ""

    $result += CreateShortcutIfRequired `
	    "C:\Program Files (x86)\UPS\WSTD\" `
	    "" `
	    "WorldShipTD.exe" `
	    "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
        "UPS WorldShip.lnk" `
	    "" `
	    ""
$result += CreateShortcutIfRequired `
	    "C:\Program Files (x86)\Mozilla Firefox\" `
	    "C:\Program Files\Mozilla Firefox\" `
	    "firefox.exe" `
	    "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\" `
        "Mozilla Firefox.lnk" `
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

	if (-not (Test-Path $shortcut)) #if the shortcut doesn't exist then create it
	{		
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
	}
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

CreateIcons