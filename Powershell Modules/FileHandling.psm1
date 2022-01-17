Import-Module '\\lan\netlogon\scripts\powershell modules\Logging.psm1'

<#
.Synopsis
    Wrapper for robocopy

.Description
    Exposed robocopy via powershell. Handles return codes from robocopy.
    Generally speaking Robocopy returns 0 - 3 as success, 4, 5, 6 and 7 as warnings, but can be treated as a success, such as extra files found in destination.
    8 onwards are errors.
    This will output the code robocopy exits with, and say if it was a success or not.

.Parameter sourceFolder
    Mandatory. The source folder to copy from

.Parameter destinationFolder
    Mandatory. The destination folder to copy to

.Parameter filesToCopy
    Optional. The files to copy, default is *.*

.Parameter options
    Optional. The options to use on the file operation.

.Example
    Robust-Copy -sourceFolder 'c:\temp' -destinationFolder 'd:\temp' -options '/E, /R:1, /W:1, /V'
    Copy all files and directories (including empty ones)

.Link
    https://ss64.com/nt/robocopy.html
    https://ss64.com/nt/robocopy-exit.html
#>
Function Invoke-Robocopy
{
    Param(
        [Parameter(Mandatory=$true)][string] $sourceFolder,
        [Parameter(Mandatory=$true)][string] $destinationFolder,
        [Parameter(Mandatory=$false)][string[]] $filesToCopy = @('*.*'),
        [Parameter(Mandatory=$false)][string[]] $options = @('')
    )


    & "robocopy" $sourceFolder $destinationFolder $filesToCopy $options

    Log-Info "Robocopy return code is $LastExitCode"

    #If $LastExitCode is greater than 8, then a file operation error occurred.
    if ($LastExitCode -gt 7)
    {
        
        switch ($LastExitCode)
        {
            8 {Log-Error 'Some files or directories could not be copied (copy errors occurred and the retry limit was exceeded). Check these errors further'}
            10 {Log-Error 'Serious error. Robocopy did not copy any files. This is either a usage error or an error due to insufficient access privileges on the source or destination directories.'}
            default {Log-Error "Robocopy encountered an error, error code: $LastExitCode"}
        }
    }
    else
    {
        Log-Info 'Robocopy was successful'
    }
    

}

<#
.Synopsis
    Trys to cleanly stop the processes

.Description
    Trys to cleanly stop the processes.
    Sleeps 5 seconds after the clean try, if the process is still open it will forcibly stop the process
    Calls Stop-ProcessCustom

.Parameter processes
    An array of (strings) processes to stop

.Example
    $processes = @('procmon', 'procmon64')
    Stop-Processes -processes $processes
#>
Function Stop-Processes
{
    Param(
        [Parameter(Mandatory=$true)][string[]] $processes
    )

    #Kill the processes if they're still open, try 'nicely' first
    foreach ($process in $processes)
    {
       Stop-ProcessCustom -process $process
    }
}

<#
.Synopsis
    Trys to cleanly stop the process

.Description
    Trys to cleanly stop the process.
    Sleeps 5 seconds after the clean try, if the process is still open it will forcibly stop the process

.Parameter processes
    A (string) process to stop

.Example
    $process = 'notepad'
    Stop-ProcessCustom -process $process
#>
Function Stop-ProcessCustom
{
    Param(
        [Parameter(Mandatory=$true)][string] $process
    )

    #Kill the processes if they're still open, try 'nicely' first
    $processHandle = Get-Process -Name $process -ErrorAction SilentlyContinue 
    if ($processHandle)
    {
        # try gracefully first
        $processHandle.CloseMainWindow()
        # kill after five seconds
        Sleep 5
        if (!$processHandle.HasExited)
        {
            $processHandle | Stop-Process -Force -ErrorAction SilentlyContinue
        }
    }
}

#Declare which functions to export/make available
Export-ModuleMember -Function 'Invoke-Robocopy'
Export-ModuleMember -Function 'Stop-ProcessCustom'
Export-ModuleMember -Function 'Stop-Processes'