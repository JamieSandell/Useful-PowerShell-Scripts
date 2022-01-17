[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Stores encypted credentials
$Livecred = Get-Credential
Import-Module MSOnline 
#Connect-MsolService -Credential $Livecred 
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Livecred -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking

#set email address of user (If using single signon use @lan.cyclops-electronics.com)
$EmailAddress = Read-Host -Prompt 'Please input the E-mail address you would like to remove from all Distribution groups:'


$user = $args[0]
if (!$args[0]) {
	
}
$mailbox=get-mailbox $EmailAddress

$dgs= Get-DistributionGroup
 
foreach($dg in $dgs){
    
    $DGMs = Get-DistributionGroupMember -identity $dg.Identity
    foreach ($dgm in $DGMs){
        if ($dgm.name -eq $mailbox.name){
       
            write-host 'User Found In Group' $dg.identity
              Remove-DistributionGroupMember $dg.Name -Member $EmailAddress
        }
    }
}

Read-Host 'Press Enter to exit...' 
Get-PSSession | Remove-PSSession