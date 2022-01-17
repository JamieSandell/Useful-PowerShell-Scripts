

$User = Read-Host "Enter users first name"
$User = "*$User*"
Get-ADComputer -Filter {Description -Like $User} -Properties Description | Select Name, Description | Format-List
Read-Host "Press any key to close"

