[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#region Example
<#
    1.) Run the script passing in a CSV file of user accounts and output the results to a log file called Set-SIPAddress.log
    powershell.exe -file "\\lan\files\netlogon\Scripts\1 - Office365\8 - SetSIPAddresses.ps1" -inputFile "C:\Temp\userAccount.csv" | Out-File c:\temp\Set-SIPAddress.log

    CSV headers are:
    UserAccount, SIPAddress, AccountType
    e.g.
    UserAccount                         SIPAddress                           AccountType
    JamieS@contoso.com                  SIP:JamiesS@contoso.com             OnPremise

    2.) Run the script, manually inputting the required data when prompted with the results output to the console window
    powershell.exe -file ".\8 - SetSIPAddresses.ps1"    
#>
#endregion

#region Parameters
param([string]$inputFile)
#endregion

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

#Returns a string containing SIP:SIPAddress@Domain if one exists based on the account type and user account passed in.
function Get-SIPAddress
{
    Param
    (
        [parameter(Mandatory=$true)]
        [String]$userAccount,
        [parameter(Mandatory=$true)]
        [ValidateSet("Cloud","OnPremise")]
        [String]$accountType
    )

    $sipAddress = $null
    $mailbox = $null

    $mailbox = Get-Mailbox -Identity $userAccount
    if ($mailbox -eq $null) #Does the mailbox exist?
    {
        Log-Error "Mailbox is null for the user account $($useraccount)"
    }
    else
    {
        if ($accountType -ieq "Cloud") #setting a SIP address is different for a cloud account in comparison to an on-premise account
        {
            [int] $sipAddressCount = 0; #we need to keep count of the sip addresses, there should only be 1 sip address present max
            foreach ($emailAddress in $mailbox.EmailAddresses)
            {
                if ($emailAddress -like "SIP:*") #Does a SIP address exist in Office 365 for the user account?
                {
                    $sipAddress = ($mailbox.EmailAddresses | Select-String -Pattern "SIP:").ToString()
                    $sipAddressCount++
                }
            }
            if ($sipAddressCount -gt 1) #error - should only be 1 SIP address max
            {
                Log-Error "There are $($sipAddressCount) SIP addresses for the user account $($userAccount)."
            }
            elseif ($sipAddressCount -eq 0)
            {
                Log-Warning "No SIP addresses exist for the user account $($userAccount) in Office 365."
            }           
        }
        elseif ($accountType -ieq "OnPremise") #setting a SIP address is different for an on-premise account in comparison to a cloud account
        {            
            $proxyAddresses = (Get-ADUser -Filter "UserPrincipalName -eq '$($userAccount)'" -Properties proxyaddresses).proxyAddresses #get the user account from AD based on the user account (upn) passed to this function            
            [int] $sipAddressCount = 0;
            foreach ($proxyAddress in $proxyAddresses)
            {
                if ($proxyAddress -like "SIP:*") #Does a SIP address exist in the proxyAddresses attribute for the user account?
                {
                    $sipAddress = ($proxyAddresses | Select-String -Pattern "SIP:").ToString()
                    $sipAddressCount++
                }
            }
            if ($sipAddressCount -gt 1)
            {
                Log-Error "There are $($sipAddressCount) SIP addresses for the user account $($userAccount)."
            }
            elseif ($sipAddressCount -eq 0)
            {
                Log-Info "No SIP addresses exist for the user account $($userAccount) in the proxyAddresses attribute in AD."
            }  
        }
        else
        {
            Log-Error "$($accountType) is not a valid account type. Valid account type is either `"Cloud`" or `"OnPremise`""
        }           
    }
    
    return $sipAddress  
}

#Passed in sipAddress needs start with SIP:, for example SIP:jamies@cyclops-electronics.com
#accountType needs to be either Cloud, or OnPremise
#userAccount should be the UPN, e.g. jamies@lan.cyclops-electronics.com if on premise, or for cloud jamies@cyclops-electronics.com
function Remove-SIPAddress
{
    Param
    (
        [parameter(Mandatory=$true)]
        [String]$userAccount,

        [parameter(Mandatory=$true)]
        [ValidatePattern("[S][I][P][:]")]
        [String]$sipAddress,

        [parameter(Mandatory=$true)]
        [ValidateSet("Cloud","OnPremise")]
        [String]$accountType
    )

    $currentSIPAddress = Get-SIPAddress -userAccount $userAccount -accountType $accountType
    if ($currentSIPAddress -eq $null) # log an error if no SIP address exists to be removed
    {
        Log-Error "No SIP address removed as no SIP address exists for the user account $($userAccount)"
    }
    
    else
    {
        if ($accountType -ieq "Cloud") # Cloud account, so look to remove the SIP address from O365 directly.
        {
            if ($currentSIPAddress -ine $sipAddress) #if the current SIP address does not equal the SIP address to be removed log an error
            {
                Log-Error "No SIP address removed as the current SIP address in AD is $($currentSIPAddress) and this does not match the SIP address $($sipAddress) to remove"
            }
            else #Otherwise remove the SIP address as we have a match
            {
                Set-Mailbox -Identity $userAccount -EmailAddresses @{remove="$($sipAddress)"}
                Log-Info "SIP address $($sipAddress) removed from the user account $($userAccount) in Office 365"
            }
        }
        elseif ($accountType -ieq "OnPremise")# On-premise account, so look to remove the SIP address from the ProxyAddresses attribute in AD
        {
            if ($currentSIPAddress -ine $sipAddress)# Does the current SIP address not equal the SIP address to remove?
            {
                Log-Error "No SIP address removed as the current SIP address in AD is $($currentSIPAddress) and this does not match the SIP address $($sipAddress) to remove"
            }
            else #Got a match, so remove the SIP address
            {
                
                $adUser = Get-ADUser -Filter "UserPrincipalName -eq '$($userAccount)'"
                Set-ADUser -Identity $adUser -Remove @{proxyaddresses = $sipAddress}
                Log-Info "SIP address $($sipAddress) removed from the user account $($userAccount) in Active Directory"
            }
        }
        else
        {
            Log-Error "$($accountType) is not a valid account type. Valid account type is either `"Cloud`" or `"OnPremise`""
        }
    }
    
}

function Set-InputFile
{
    Param
    (
        [parameter(Mandatory=$true)]
        [String]$inputFile


    )
}

#Gets the current SIP address, removes it (if one exists) and then sets the new one
function Set-SIPAddress
{
    Param
    (
        [parameter(Mandatory=$true)]
        [String]$userAccount,

        [parameter(Mandatory=$true)]
        [ValidatePattern("[S][I][P][:]")]
        [String]$sipAddress,

        [parameter(Mandatory=$true)]
        [ValidateSet("Cloud","OnPremise")]
        [String]$accountType
    )

    $currentSIPAddress = Get-SIPAddress -userAccount $userAccount -accountType $accountType
    if ($currentSIPAddress -eq $null) #Does the account even have a SIP address currently?
    {
        Log-Info "There is currently no SIP address for the user account $($userAccount)"
    }
    else #Print out what the current SIP address is
    {
        Log-Info "The current SIP address for the user account $($userAccount) is $($sipAddress)"
    }
    
    if ($currentSIPAddress -ieq $sipAddress) #Does the current SIP address already match what we want to set it to?
    {
        Log-Info "The sip address of the user account $($userAccount) is already set to $($sipAddress), no changes made."
    }
    else
    {
        if ($accountType -ieq "Cloud")
        {   
            Remove-SIPAddress -userAccount $userAccount -accountType $accountType -sipAddress $sipAddress            
            Set-Mailbox -Identity $userAccount -EmailAddresses @{add="SIP:$($sipAddress)"}
            Log-Info "SIP address set to $($sipAddress) for the user account $($userAccount)"
        }
        elseif ($accountType -ieq "OnPremise")
        {
            Remove-SIPAddress -userAccount $userAccount -accountType $accountType -sipAddress $sipAddress
            $adUser = Get-ADUser -Filter "UserPrincipalName -eq '$($userAccount)'"
            Set-ADUser -Identity $adUser -Add @{proxyaddresses = $sipAddress}
        }
        else
        {
            Log-Error "$($accountType) is not a valid account type. Valid account type is either `"Cloud`" or `"OnPremise`""
        }
    }
}
#endregion

#region Connect to O365
$userCredential = Get-Credential
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $userCredential -Authentication  Basic -AllowRedirection
Import-PSSession $session

Connect-MsolService -Credential $userCredential
#endregion

if (-not $inputFile) #manual input required?
{
    $userAccount = Read-Host "Please enter the user account you want to change the SIP address of - e.g. jamies@lan.contoso.com for an OnPremise account, or jamies@contoso.com for a Cloud account."
    $sipAddress = Read-Host "Please enter the SIP address to set it to, e.g. SIP:jamies@cyclops-electronics.com"
    $accountType = Read-Host "Please enter the account type, either Cloud or OnPremise"

    Set-SIPAddress -userAccount $userAccount -sipAddress $sipAddress -accountType $accountType
}    
else #otherwise automate the task
{
    #region Read the CSV file passed in
    $input = Import-Csv -Path $inputFile -Delimiter ","
    #endregion

    #region Set the SIP address based on the data in the file passed in
    Foreach ($row in $input)
    {
        Set-SIPAddress -userAccount $row.UserAccount -sipAddress $row.SIPAddress -accountType $row.AccountType
    }
    #endregion
}



#region Tidy up after ourselves
Remove-PSSession $session
#endregion



