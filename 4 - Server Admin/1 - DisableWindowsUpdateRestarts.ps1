#region Functions
function Log-Info
{
    [CmdletBinding()]
    Param
    (
        [parameter(Mandatory=$true, Position=0)]
        [String]$logInfo
    )

    Write-Output ("{1} - {0} - {2}" -f (Get-Date), "INFO", $logInfo)
}

function Log-Error
{
    [CmdletBinding()]
    Param
    (
        [parameter(Mandatory=$true, Position=0)]
        [String]$logError
    )

    Write-Output ("{1} - {0} - {2}" -f (Get-Date), "ERROR", $logError)
}

function Log-Warning
{
    [CmdletBinding()]
    Param
    (
        [parameter(Mandatory=$true, Position=0)]
        [String]$logError
    )

    Write-Output ("{1} - {0} - {2}" -f (Get-Date), "WARNING", $logError)    
}
#endregion


Import-Csv "C:\temp\serverList.csv" -Header Servers | Foreach-Object{

    #Is the server 2016?
    $OS = Get-WmiObject -ComputerName $_.Servers -Class Win32_OperatingSystem
    if ($OS.Caption -like '*Windows Server 2016*') #Only applicable for Windows Server 2016
    {
        #region Disable the Reboot task
        $taskToDisable = "\Microsoft\Windows\UpdateOrchestrator\Reboot"
        $task = $null
        $task = Get-ScheduledTask -TaskPath "\Microsoft\Windows\UpdateOrchestrator\" -TaskName "Reboot" -CimSession $_.Servers
        if ($task -eq $null) #If the task exists for rebooting then disable it
        {
            #The task doesn't exist
            Log-Error "The task $($taskToDisable) does not exist on $($_.Servers)"
        }
        elseif ($task.State -eq "disabled")
        {
            #The task is already disabled
            Log-Info "The task $($taskToDisable) is already disabled on $($_.Servers)"
        }
        else
        {
            #The task exists and isn't disabled, so disable it
            Disable-ScheduledTask -TaskName "\Microsoft\Windows\UpdateOrchestrator\Reboot" -CimSession $_.Servers
            Log-Info "The task $($taskToDisable) has been disabled for $($_.Servers)"
        }
        #endregion

        #region Rename the reboot file
        $rebootFilePath = "\\$($_.Servers)\C$\Windows\System32\Tasks\Microsoft\Windows\UpdateOrchestrator\Reboot"
        if (Test-Path -Path $rebootFilePath -PathType leaf)
        {
            #File exists so rename it
            Rename-Item $rebootFilePath -NewName "Reboot.bak"
            Log-Info "$($rebootFilePath) has been renamed to Reboot.bak on $($_.Servers)"
        }
        else
        {
            #The file doesn't exist
            Log-Info "The file $($rebootFilePath) does not exist on $($_.Servers)"
        }
        #endregion
    
        #region Create the Reboot folder, this prevents Windows from recreating the reboot file, as a folder and file cannot share the same name in the same directory.
        $folderToCreate = "\\$($_.Servers)\C$\Windows\System32\Tasks\Microsoft\Windows\UpdateOrchestrator\Reboot"
        if (Test-Path $folderToCreate)
        {
            Log-Info "The folder to create $($folderToCreate) already exists on $($_.Servers)"
        }
        else
        {
            New-Item -ItemType Directory -Path $folderToCreate
            Log-Info "$($folderToCreate) has been created on $($_.Servers)"
        }
        #endregion
    }
    else
    {
        Log-Info "$($_.Servers) is not running Windows Server 2016, it is running $($OS.Caption), no further action required"
    }
    
    
}