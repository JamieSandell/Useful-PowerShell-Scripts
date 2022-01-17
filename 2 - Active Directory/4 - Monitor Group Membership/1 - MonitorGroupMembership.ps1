<#
Script to monitor changes to AD group memberships, specifically the adding and removing of members.
The script reads in a CSV file called GroupsToMonitor.csv that contains all of the groups to monitor.

**Example GroupsToMonitor.csv**
Groups
SG_Accounts_Users
SG_Third_Parties
SG_Office_Desktops

The script then checks for a CSV file called GroupMembership.csv.
If this script doesn't exist then it will set the $firstRun flag to $true.

If the $firstRun flag is true the script will then:
1. Delete the GroupMembership.csv file if it exists
2. Create the GroupMembership.csv file if it doesn't exist
3. Query AD group membership from the groups defined in GroupsToMonitor.csv
4. Enter all memberships of the groups defined in GroupsToMonitor.csv

If the $firstRun flag is false the script will then:
1. Query the AD group membership from the groups defined in GroupsToMonitor.csv
2. The GroupMembership.csv file will then be read in
3. Results from step 1 will be compared with results from step 2
4. Any discrepencies will be put in to one of two camps, Added or Removed
5. This will be outputted to a results file which will be date and time stamped.
6. This information will be sent to the helpdesk
7. The GroupMembership.csv file will be updated from step 2
#>

#region Functions
#region Logging Functions
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
#endregion

#region Variables
#region Logic Variables
[bool]$firstRun
#endregion
#region E-mail Variables
$smtpServer = "smtp.test.com.example"
$fromAddress = "proactive@contoso.com"
$toAddress = "helpdesk@contoso.com"
$emailSubject = ""
$emailBody = ""
#endregion
#region File Variables
$groupMembershipCSV = ".\groupMembershipCSV"
$groupsToMonitorCSV = ".\groupsToMonitorCSV"
#endregion
#endregion

if ((Test-Path -Path $groupMembershipCSV) -eq $false)
{
    Log-Info "$($groupMembershipCSV) does not exist."
    $firstRun = $true
    Log-Info "firstRun set to $($firstRun)"
}
else
{
    Log-Info "$($groupMembershipCSV) exists."
    $firstRun = $false
    Log-Info "firstRun set to $($firstRun)"
    #Query the AD group membership from the groups defined in GroupsToMonitor.csv
    if ((Test-Path -Path $groupsToMonitorCSV) -eq $false)
    {
        Log-Error "$($groupsToMonitorCSV) does not exist. Please create it with the groups you want to read in. $(
        )**Example GroupsToMonitor.csv** $(
        )Groups $(
        )SG_Account_Users $(
        )SG_Third_Parties $(
        )SG_Office_Desktops"
    }
    else
    {
        Log-Info "$($groupsToMonitorCSV) exists."

    }
}

