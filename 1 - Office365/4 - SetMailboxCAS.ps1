[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
<#
The script does the following:
    1. Prompt for a bulk job or single job
    2. Prompt for credentials for the account that has permission to modify CAS for a mailbox
    3. Connect to O365
    4. Perform the job
#>

#region functions
Function Get-UserInput
{
    <#
    .SYNOPSIS
        This function gets the user input and loops until valid input has been entered

    .PARAMETER The parameter textToDisplay is the text to display when prompting for the user's input

    .PARAMETER The parameter acceptableInputs is an array of strings that dictates what is acceptable input

    .RETURN Returns the valid input entered by the user

    .EXAMPLE
        Get-UserInput -textToDisplay "Do you want to enable EWS? Y/N" -acceptableInputs @("Y","N")
    #>
    Param
    (
        [Parameter(Mandatory=$true)]
        [string[]]$acceptableInputs,

        [Parameter(Mandatory=$true)]
        [string[]]$textToDisplay
    )
    $userInput
    do
    {
        $userInput = Read-Host $textToDisplay
        $validInput = $false
        foreach ($acceptableInput in $acceptableInputs)
        {
            if ($userInput -like $acceptableInput) #Has the user entered a valid input?
            {
                $validInput = $true
                break #no need to keep looping if valid input has been entered
            }
        }
        if ($validInput -eq $false)
        {
            Write-Error "Invalid input entered, please enter one of the following $acceptableInputs"
        }    
    } until(($userInput -like "Y") -or ($userInput -like "N")) #loop until the user has entered Y or N
    return $userInput
}

Function Set-CAS
{
    <#
    .SYNOPSIS
        This function will set various properties of CAS to be enabled or disabled for a mailbox

    .PARAMETER The parameter identity is the identity of the mailbox, e.g. "Jamie Sandell"

    .PARAMETER The parameter enableEWS is used to enable or disable EWS

    .PARAMETER The parameter enablePop is used to enable or disable POP

    .PARAMETER The parameter enableImap is used to enable or disable IMAP

    .PARAMETER The parameter enableActiveSync is used to enable or disable ActiveSync

    .PARAMETER The parameter enableOWA is used to enable or disable OWA

    .EXAMPLE
        The example below disables EWS, POP, Imap, ActiveSync and enables OWA for Jamie Sandell
        Set-CAS -Identity "Jamie Sandell" -enableEWS $false -enablePop $flase -enableImap $false -enableActiveSync $false -enableOWA $false
    #>
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]$identity,

        [Parameter(Mandatory=$true)]
        [bool]$enableEws,

        [Parameter(Mandatory=$true)]
        [bool]$enablePop,

        [Parameter(Mandatory=$true)]
        [bool]$enableImap,

        [Parameter(Mandatory=$true)]
        [bool]$enableActiveSync,

        [Parameter(Mandatory=$true)]
        [bool]$enableOWA,

        [Parameter(Mandatory=$true)]
        [bool]$enableOWAForDevices

    )

    Write-Output "Setting EwsEnabled for $identity to $enableEws"
    Write-Output "Setting PopEnabled for $identity to $enablePop"
    Write-Output "Setting ImapEnabled for $identity to $enableImap"
    Write-Output "Setting ActiveSyncEnabled for $identity to $enableActiveSync"
    Write-Output "Setting OWAEnabled for $identity to $enableOWA"
    Write-Output "Setting OWAforDevicesEnabled for $identity to $enableOWAForDevices"
    Set-CASMailbox -Identity $identity -EwsEnabled $enableEws -PopEnabled $enablePop -ImapEnabled $enableImap -ActiveSyncEnabled $enableActiveSync -OWAEnabled $enableOWA -OWAforDevicesEnabled $enableOWAForDevices
}
#endregion

$bulkJob = $true
#region Prompt for a bulk job or single job
$userInput = Get-UserInput -textToDisplay "Do you want to run a bulk job? Y/N" -acceptableInputs @("Y","N")
if ($userInput -like "Y")
{
    $bulkJob = $true
}
elseif ($userInput -like "N")
{
    $bulkJob = $false
}
#endregion

#region Prompt for credentials for the account that has permission to modify CAS for a mailbox
Write-Output "`n"
$username = Read-Host "Please enter the username that has rights to modify the CAS"
Write-Output "`n"
$password = Read-Host -AsSecureString "Please enter the password for $username"

#build our credential object for use later
$userCredential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $password
#endregion

#region Connect to O365
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $userCredential -Authentication  Basic -AllowRedirection
Import-PSSession $session
#endregion

#region Perform the job
$myObjects = @()
$mailbox

#If we are doing a bulk job read the contents of the CSV file containing the identities
$csv
if ($bulkJob -eq $true)
{
    Read-Host "Press Enter to select the CSV file containing the identities"
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null #we don't want the info returned from this, of no use
    $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $result = $fileDialog.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))
    if ($result -eq [Windows.Forms.DialogResult]::OK)
    {
        $csv = Import-Csv -Path $fileDialog.filename
    }
    else
    {
        Write-Error "No CSV file for selected for the bulk job."
    }
}
else #we aren't doing a bulk job so ask the user to supply the identity of the mailbox
{
    $userInput = $null
    do
    {
        $userInput = Read-Host "Please enter the Identity of the mailbox, e.g. joe.bloggs@contoso.com"
        $mailbox = $userInput
    } until($userInput)   
}
#Check if we are enabling or disabling EWS, Pop, Imap, ActiveSync and OWA
$acceptableInputYN = @("Y", "N")
if ($bulkJob -eq $false)
{
    #User opted to run a single job not a bulk job
    #Check for each setting if they want to enable or disable it
    if ((Get-UserInput -textToDisplay "Do you want to enable Ews? Y/N" -acceptableInputs $acceptableInputYN) -like "Y")
    {
        $enableEWS = $true
    }
    else
    {
        $enableEWS = $false
    }
    if ((Get-UserInput -textToDisplay "Do you want to enable POP? Y/N" -acceptableInputs $acceptableInputYN) -like "Y")
    {
        $enablePop = $true
    }
    else
    {
        $enablePop = $false
    }
    if ((Get-UserInput -textToDisplay "Do you want to enable IMAP? Y/N" -acceptableInputs $acceptableInputYN) -like "Y")
    {
        $enableImap = $true
    }
    else
    {
        $enableImap = $false
    }
    if ((Get-UserInput -textToDisplay "Do you want to enable ActiveSync? Y/N" -acceptableInputs $acceptableInputYN) -like "Y")
    {
        $enableActiveSync = $true
    }
    else
    {
        $enableActiveSync = $false
    }
    if ((Get-UserInput -textToDisplay "Do you want to enable OWA? Y/N" -acceptableInputs $acceptableInputYN) -like "Y")
    {
        $enableOWA = $true
    }
    else
    {
        $enableOWA = $false
    }
    if ((Get-UserInput -textToDisplay "Do you want to enable OWAforDevices? Y/N" -acceptableInputs $acceptableInputYN) -like "Y")
    {
        $enableOWAForDevices = $true
    }
    else
    {
        $enableOWAForDevices = $false
    }

    #Got all our settings so make the change
    Set-CAS -identity $mailbox -enableEws $enableEWS -enablePop $enablePop -enableImap $enableImap -enableActiveSync $enableActiveSync -enableOWA $enableOWA -enableOWAForDevices $enableOWAForDevices
}
else #bulkjob
{
    $enableEws
    $enablePop
    $enableImap
    $enableActiveSync
    $enableOWA
    $enableOWAForDevices

    foreach ($row in $csv)
    {
        $row.EwsEnabled
        $enableEws = [bool]::Parse($row.EwsEnabled)
        $enablePop = [bool]::Parse($row.PopEnabled)
        $enableImap = [bool]::Parse($row.ImapEnabled)
        $enableActiveSync = [bool]::Parse($row.ActiveSyncEnabled)
        $enableOWA = [bool]::Parse($row.OWAEnabled)
        $enableOWAForDevices = [bool]::Parse($row.OWAForDevicesEnabled)

        Write-Output "Processing mailbox for $row.PrimarySmtpAddress"
        Set-CAS -identity $row.PrimarySmtpAddress -enableEws $enableEWS -enablePop $enablePop -enableImap $enableImap -enableActiveSync $enableActiveSync -enableOWA $enableOWA -enableOWAForDevices $enableOWAForDevices
        Write-Output "Processed mailbox for $row.PrimarySmtpAddress"
    }
}
#endregion

Remove-PSSession -Session $session

