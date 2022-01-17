Import-Module ActiveDirectory
$serialnumber = gwmi win32_bios | Select-Object SerialNumber
$date = get-date -Format "dd/MM/yyyy"
$computerInfo = Get-ComputerInfo
$user = Get-ADUser $env:USERNAME

$description = "$($user.Name) - $($computerInfo.CsModel) - $($computerInfo.BiosSeralNumber) - $date"

Set-ADComputer -Identity $computerInfo.CsName -Description $description