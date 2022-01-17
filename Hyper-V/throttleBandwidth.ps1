<#
Asks for the Hyper-V host to set the throttling for.
Asks for the work hour bandwidth in Mbps.
Asks for the non-work hour bandwidth in Mbps.
#>

$server = Read-Host -Prompt "Please enter the host name to throttle replication bandwidth"


[int] $workHourBandwidth = 0
do
{
    $userInput = Read-Host -Prompt "Please enter the work hour bandwidth in Mbps"
    [int]::TryParse($userInput, [ref]$workHourBandwidth) #Outputs the number if it successfully converts the string to an int to [ref]$variableName
    #Outputs 0 if it failes to convert the string to an int to [ref]$variableName

}until ($workHourBandwidth -gt 0)
$workHourBandwidth = $workHourBandwidth * 1024 * 1024

[int] $nonWorkHourBandwidth = 0
do
{
    $userInput = Read-Host -Prompt "Please enter the non-work hour bandwidth in Mbps"
    $returnValue = ""
    [int]::TryParse($userInput, [ref]$nonWorkHourBandwidth)

}until ($nonWorkHourBandwidth -gt 0)
$nonWorkHourBandwidth = $nonWorkHourBandwidth * 1024 * 1024

$scriptBlock = {
    param(
        $workHourBandwidth,
        $nonWorkHourBandwidth
    )

    $mon = [System.DayOfWeek]::Monday
    $tue = [System.DayOfWeek]::Tuesday
    $wed = [System.DayOfWeek]::Wednesday
    $thu = [System.DayOfWeek]::Thursday
    $fri = [System.DayOfWeek]::Friday
    $sat = [System.DayOfWeek]::Saturday
    $sun = [System.DayOfWeek]::Sunday


    Set-OBMachineSetting -WorkDay $mon, $tue, $wed, $thu, $fri -StartWorkHour "8:00:00" -EndWorkHour "23:00:00" -WorkHourBandwidth  $workHourBandwidth -NonWorkHourBandwidth $nonWorkHourBandwidth
}

Invoke-Command -ComputerName $server -ScriptBlock $scriptBlock -ArgumentList $workHourBandwidth, $nonWorkHourBandwidth