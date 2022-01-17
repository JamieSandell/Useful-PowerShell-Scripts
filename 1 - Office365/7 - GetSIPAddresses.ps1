[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
<#
1. Get all users
2. Export a CSV of cloud only accounts with their SIP address
3. Export a CSV of AD synced accounts with their SIP address
#>

#region Functions
Function New-AccountObject ($account)
{
    $newObject = New-Object -TypeName PSObject
    $newObject | Add-Member -MemberType NoteProperty -Name UserAccount -Value $account.UserPrincipalName
    #calculate the PrimarySMTPAddress
    $primarySMTPAddress = ($account.ProxyAddresses | Select-String -Pattern "SMTP:" -CaseSensitive).ToString()
    #$primarySMTPAddress = $primarySMTPAddress.Remove(0, 5) #Remove SMTP
    $newObject | Add-Member -MemberType NoteProperty -Name PrimarySMTPAddress -Value $primarySMTPAddress
    #calculate the SIP Address
    $mailbox = Get-CASMailbox -Identity $account.UserPrincipalName #Get-MSOLUser.ProxyAddresses only returns SMTP, but we need SIP
    if ($mailbox -eq $null)
    {
        $SIPAddress = "No mailbox associated with the user account"
    }
    else
    {
        $SIPAddress = ($mailbox.EmailAddresses | Select-String -Pattern "SIP:").ToString()
        #$SIPAddress = $SIPAddress.Remove(0, 4) #Remove SIP:
    }
    
    $newObject | Add-Member -MemberType NoteProperty -Name SIPAddress -Value $SIPAddress

    return $newObject
}
#endregion

#region Connect to O365
$userCredential = Get-Credential
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $userCredential -Authentication  Basic -AllowRedirection
Import-PSSession $session

Connect-MsolService -Credential $userCredential
#endregion

$accounts = get-msoluser -all

$accountsToExport =@()
foreach ($account in $accounts)
{
    if (($account.immutableid -eq $null) -and ($account.IsLicensed -eq $true)) #cloud accounts do not have a value for the immutableid property
    {
        $tempObject = New-AccountObject $account
        $tempObject | Add-Member -MemberType NoteProperty -Name AccountType -Value "Cloud"
        $accountsToExport += $tempObject    
    }
    elseif (($account.immutableid -ne $null) -and ($account.IsLicensed -eq $true))
    {
        $tempObject = New-AccountObject $account
        $tempObject | Add-Member -MemberType NoteProperty -Name AccountType -Value "OnPremise"
        $accountsToExport += $tempObject
    }        
}

$exportPath = "c:\temp\"
$exportFile = "AccountsSIP.csv"
if ((Test-Path -Path $exportPath) -eq $false)
{
    New-Item -Path $exportPath
}
$accountsToExport | Export-Csv -Path ($exportPath+$exportFile) -NoTypeInformation

Remove-PSSession $session