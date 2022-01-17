# Session.FileTransferred event handler
[int]$script:numberOfFilesSynchronised = 0
[int]$script:numberOfFilesFailed = 0
[string[]]$script:filesSynchronised = @()
[string[]]$script:filesFailed = @()
function FileTransferred
{
    param($e)    
 
    if ($e.Error -eq $Null)
    {
        Log-Info "Upload of $($e.FileName) succeeded"
        $script:numberOfFilesSynchronised++
        $script:filesSynchronised += $e.FileName
    }
    else
    {
        Log-Error "Upload of $($e.FileName) failed: $($e.Error)"
        $script:numberOfFilesFailed++
        $script:filesFailed += $e.FileName
    }
 
    if ($e.Chmod -ne $Null)
    {
        if ($e.Chmod.Error -eq $Null)
        {
            Log-Info "Permissions of $($e.Chmod.FileName) set to $($e.Chmod.FilePermissions)"
        }
        else
        {
            Log-Error "Setting permissions of $($e.Chmod.FileName) failed: $($e.Chmod.Error)"
        }
 
    }
    else
    {
        #Log-Info "Permissions of $($e.Destination) kept with their defaults"
    }
 
    if ($e.Touch -ne $Null)
    {
        if ($e.Touch.Error -eq $Null)
        {
            Log-Info "Timestamp of $($e.Touch.FileName) set to $($e.Touch.LastWriteTime)"
        }
        else
        {
            Log-Error "Setting timestamp of $($e.Touch.FileName) failed: $($e.Touch.Error)"
        }
 
    }
    else
    {
        # This should never happen during "local to remote" synchronization
        #Log-Info "Timestamp of $($e.Destination) kept with its default (current time)"
    }
}

function FileTransferProgress
{
    param($e)
 
    # New line for every new file
    if (($script:lastFileName -ne $Null) -and
        ($script:lastFileName -ne $e.FileName))
    {
        Write-Host
    }
 
    # Print transfer progress
    Write-Host -NoNewline ("`r{0} ({1:P0})" -f $e.FileName, $e.FileProgress)
 
    # Remember a name of the last file reported
    $script:lastFileName = $e.FileName
}

<#
.Synopsis
    Synchronises two directories, one local one FTP.
    Uses date and time comparison to only copy files that are newer
    Wrapper function for WinSCP Assembly

.Parameter Hostname
    String - Mandatory - The hostname of the FTP server

.Parameter Username
    String - Mandatory - Username used to connect to the FTP server

.Parameter Password
    String - Mandatory - Password used to connect to the FTP server

.Parameter RemotePath
    String - Mandatory - The path to copy from

.Parameter LocalPath
    String - Mandatory - The path to copy to

.Example
    Synchronise-Directory -Hostname 'LantekFTP.lan.cyclops-electronics.com' -Username 'admin' -Password 'password' -RemotePath '/Cyclops/CoDoc' -LocalPath 'C:\Backup'

.Link https://winscp.net/eng/docs/library_session_synchronizedirectories
    
#>
function Synchronise-Directory
{
    Param(
        [Parameter(Mandatory=$true)][string] $hostname,
        [Parameter(Mandatory=$false)][int] $portNumber = 21,
        [Parameter(Mandatory=$true)][string] $username,
        [Parameter(Mandatory=$true)][string] $password,
        [Parameter(Mandatory=$true)][string] $remotePath,
        [Parameter(Mandatory=$true)][string] $localPath,
        [Parameter(Mandatory=$false)][string] $fileMask,
        [Parameter(Mandatory=$false)][string] $synchronizationMode = 'Local'
    )
    try
    {
        #Set our session options
        Log-Info 'Setting session options'
        $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
            Protocol = [WinSCP.Protocol]::Ftp
            HostName = $hostname
            PortNumber = $portNumber
            UserName = $username
            Password = $password
        }
        Log-Info 'Session options set to:'
        $sessionOptions | Select-Object -Property * -ExcludeProperty 'Password' # Don't log the password

        #Set our transfer options
        Log-Info 'Setting transfer options'
        $transferOptions = New-Object WinSCP.TransferOptions -Property @{
            FileMask = $fileMask
        }
        Log-Info 'Transfer options set to:'
        $transferOptions | Select-Object -Property *
        
        #Create our session, set the timeout and syncMode
        $session = New-Object WinSCP.Session

        #Try to transfer the files
        try
        {
            Log-Info "Starting transfer of files"
            $session.add_FileTransferred( { FileTransferred($_) } )
            #$session.add_FileTransferProgress( { FileTransferProgress($_) } )
            $session.add_QueryReceived( { 
                Log-Error "$($_.Message)"
                $_.Continue()
            } )
            Log-Info "Connecting to $hostname"
            $session.Open($sessionOptions)
            #Params for SynchronizeDirectories
            #SynchronizationMode, localPath, remotePath, removeFiles, mirror, SynchronizationCriteria, TransferOptions
            $synchronisationResult = $session.SynchronizeDirectories($synchronizationMode, $localPath, $remotePath, $false, $false, [WinSCP.SynchronizationCriteria]::Time, $transferOptions)
            $synchronisationResult.Check()
        }
        catch
        {
            Log-Error "$($_.Exception.Message)"
        }
        finally
        {
            Display-Summary

            $session.Dispose()
            Log-Info "Disconnected from $hostname"
        }
    }
    catch
    {
        Log-Error "$($_.Exception.Message)"
    }
}

function Display-Summary
{
    Display-Failures
    Display-Successes
}

function Display-Failures
{
    Log-Info 'Finished synchronising files'
    Write-Host '----------- Failed Files -----------'
    $script:filesFailed | `
        foreach-object {
            Write-Host $_
        }
    Log-Info "Number of files that failed to synchronise - $($script:numberOfFilesFailed)"
}

function Display-Successes
{
    Write-Host '----------- Successful Files -----------'
    <#
    $script:filesSynchronised | `
        foreach-object {
            Write-Host $_
        }
    #>
    Log-Info "Number of files successfully synchronised - $($script:numberOfFilesSynchronised)"
}

function Put-Files
{
    Param(
        [Parameter(Mandatory=$true)][string] $hostname,
        [Parameter(Mandatory=$false)][int] $portNumber = 21,
        [Parameter(Mandatory=$true)][string] $username,
        [Parameter(Mandatory=$true)][string] $password,
        [Parameter(Mandatory=$true)][string] $localPath,
        [Parameter(Mandatory=$true)][string] $remotePath,
        [Parameter(Mandatory=$false)][WinSCP.FtpMode] $ftpMode = [WinSCP.FtpMode]::passive
    )

    #Set our session options
    Log-Info 'Setting session options'
    $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
        Protocol = [WinSCP.Protocol]::ftp
        HostName = $hostname
        PortNumber = $portNumber
        UserName = $username
        Password = $password
        FtpMode = $ftpMode
    }
    Log-Info 'Session options set to:'
    $sessionOptions | Select-Object -Property * -ExcludeProperty 'Password' # Don't log the password

    $session = New-Object WinSCP.Session

    try
    {
        #Connect
        $session.Open($sessionOptions)

        #upload the files and collect the results
        $transferResult = $session.PutFiles($localPath, $remotePath)

        #Iterate over each transfer
        foreach ($transfer in $transferResult.Transfers)
        {
            #Success or error?
            if ($transfer.Error -eq $Null)
            {
                Log-Info  "Upload of $($transfer.FileName) succeeded."
            }
            else
            {
                Log-Error "Upload of $($transfer.FileName) failed: $($transfer.Error.Message)"
            }
        }
    }
    catch
    {
        Log-Error "Error: $($_.Exception.Message)"
    }    
    finally
    {
        $session.Dispose()
    }
}

Import-Module -Name '\\lan\netlogon\scripts\powershell modules\Logging.psm1'
#Load WinSCP .NET assembly
Add-Type -Path '\\lan\files\Installers\WinSCP\WinSCPnet.dll'

Export-ModuleMember -Function 'Synchronise-Directory'
Export-ModuleMember -Function 'Put-Files'