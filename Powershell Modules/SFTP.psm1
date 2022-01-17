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
    
#>
function Synchronise-Directory
{
    Param(
        [Parameter(Mandatory=$true)][string] $hostname,
        [Parameter(Mandatory=$true)][string] $username,
        [Parameter(Mandatory=$true)][string] $password,
        [Parameter(Mandatory=$true)][string] $remotePath,
        [Parameter(Mandatory=$true)][string] $localPath,
        [Parameter(Mandatory=$false)][int] $timeoutInSeconds = 120,
        [Parameter(Mandatory=$false)][string] $fileMask,
        [Parameter(Mandatory=$false)][int] $speedLimit
    )
    try
    {
        #Set our session options
        Log-Info 'Setting session options'
        $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
            Protocol = [WinSCP.Protocol]::Sftp
            HostName = $hostname
            UserName = $username
            Password = $password
            GiveUpSecurityAndAcceptAnySshHostKey = $true
        }
        Log-Info 'Session options set to:'
        $sessionOptions | Select-Object -Property * -ExcludeProperty 'Password' # Don't log the password

        #Set our transfer options
        Log-Info 'Setting transfer options'
        $transferOptions = New-Object WinSCP.TransferOptions
        if ($fileMask) #Was a fileMask specified?
        {
            $transferOptions.FileMask = $fileMask
        }
        else
        {
            Log-Info 'No file mask set'
        }
        if ($speedLimit)
        {
            $transferOptions.SpeedLimit = $speedLimit
        }
        else
        {
            Log-Info 'No speed limit set'
        }
        Log-Info 'Transfer options set to:'
        Write-Output $transferOptions #Log-Info can't handle objects and their properties

        #Create our session, set the timeout and syncMode
        $session = New-Object WinSCP.Session
        $session.Timeout = New-TimeSpan -Seconds $timeoutInSeconds
        $synchronisationMode = [WinSCP.SynchronizationMode]::Local

        #Try to transfer the files
        try
        {
            Log-Info "Starting transfer of files"
            $session.add_FileTransferred( { FileTransferred($_) } ) #Raise an event every time a file has been transferred
            #$session.add_FileTransferProgress( { FileTransferProgress($_) } )
            $session.add_QueryReceived( { #Raise an event every time a query is received.
                Log-Error "$($_.Message)"
                $_.Continue()
            } )
            Log-Info "Connecting to $hostname"
            $session.Open($sessionOptions) #Open our session
            #Sync the directory from the source folder to the destination folder.
            $synchronisationResult = $session.SynchronizeDirectories($synchronisationMode, $localPath, $remotePath, $false) #TODO check all possible function parameters possible.
            $synchronisationResult.Check() #Check for any issues
        }
        catch
        {
            Log-Error "$($_.Exception.Message)"
        }
        finally
        {
            Display-Summary #If the script hasn't caused any exception, display the summary

            $session.Dispose()#Tidy up after ourselves
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


Import-Module -Name '\\lan\netlogon\scripts\powershell modules\Logging.psm1'
#Load WinSCP .NET assembly
Add-Type -Path '\\lan\files\Installers\WinSCP\WinSCPnet.dll'

Export-ModuleMember -Function 'Synchronise-Directory'