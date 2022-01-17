<#
Change $printServer to the name of the print server you want details from.

When run it exports a CSV of printernames and their host address. Exports to c:\temp\$printServer.csv
#>
$printServer = "PrintServer01"

gwmi win32_printer -ComputerName $printServer | %{ $printer = $_.Name; $port = $_.portname; gwmi win32_tcpipprinterport -computername $printServer | where { $_.Name -eq $port } | select @{name="printername";expression={$printer}}, hostaddress, location } | Export-CSV -path "C:\\temp\\$($printServer).csv" -NoTypeInformation