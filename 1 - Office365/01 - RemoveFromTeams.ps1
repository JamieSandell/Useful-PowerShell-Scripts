Install-Module MicrosoftTeams
Import-Module MicrosoftTeams

$credential = Get-Credential

#Connect to Microsoft Teams
Connect-MicrosoftTeams -Credential $credential

#Prompt for the user
$user = Read-Host -Prompt 'Please input the E-mail address you would like to remove from all Teams groups:'
$teams = Get-Team -user $user
foreach ($team in $teams) {
    Remove-TeamUser -GroupId $team.GroupId -User $user
}