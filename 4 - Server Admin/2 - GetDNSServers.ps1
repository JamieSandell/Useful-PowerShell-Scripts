function Get-DNSServers()
{
    <#
    .SYNOPSIS
    This functions gets the Primary and Alternate DNS Servers from a machine

    .DESCRIPTION
    This functions gets the Primary and Alternate DNS Servers from a machine
    Th computerName parameter is ignored if the computerList parameter is specified.
    If the computerList parameter is not specified, and this parameter is not specified then localhost will be used

    .PARAMETER computerName
    The text of the computer to read the DNS server settings from.

    .PARAMETER computerList
    A file containing a list of computers to get the DNS information from

    .PARAMETER outFile
    A CSV file that will be written to when the DNS has been retrieved.

    .EXAMPLE
    Get-DNSServers
    This will produce the preferred and alternate DNS servers of the localhost

    .EXAMPLE
    Get-DNSServers -computerName 'PC01'
    This will produce the preferred and alternate DNS servers of the localhost

    .EXAMPLE
    Get-DNSServers -computerName 'PC02 -outFile 'C:\temp\DNSServerInfo.csv'
    This will produce the preferred and alternate DNS servers of the localhost and export it to C:\temp\DNSServerInfo.csv

    .EXAMPLE
    Get-DNSServers -computerList 'C:\temp\computerList.txt'
    This will read in a list of comptuers from a txt file and get their preferred and alternate DNS servers

    .EXAMPLE
    Get-DNSServers -computerList 'C:\temp\computerList.txt' -outFile 'C:\temp\DNSServerInfo.csv'
    This will read in a list of computers from a txt file, get their preferred and alternate DNS servers and output it to C:\temp\DNSServerInfo.csv
    #>

    Param(
        [Parameter(Mandatory=$false)][string]$computerName = 'localhost',
        [Parameter(Mandatory=$false)][string]$computerList = "",
        [Parameter(Mandatory=$false)][string]$outFile = ""
    )

    $servers = [System.Collections.ArrayList]@() #server object list

    #Is the computer running Windows Server 2012 or 2016?
    
    if ($computerList -eq "") #Using the default value, so process the localhost
    {
        #Only interested in servers that are running 2012 or 2016
        $OS = Get-WmiObject -ComputerName $computerName -Class Win32_OperatingSystem
        if (($OS.Caption -like '*Windows Server 2016*') -or ($OS.Caption -like '*Windows Server 2012*'))
        {
            [Servers]$server = Get-DNSServersHelper -computerName $computerName
            $servers.Add($server)
        }
    }
    else #a list of computers was specified so process them
    {
        $computers = Get-Content -Path $computerList #read the computers from the txt file        
        
        foreach ($computer in $computers) #process each computer one by one
        {
            #Only interested in servers that are running 2012 or 2016
            $OS = Get-WmiObject -ComputerName $computer -Class Win32_OperatingSystem
            if (($OS.Caption -like '*Windows Server 2016*') -or ($OS.Caption -like '*Windows Server 2012*'))
            {
                [Servers]$server = Get-DNSServersHelper -computerName $computer #Get the DNS info and add it to a server object.
                $servers.Add($server) #add the server object we just created and got info for to our list of server objects
            }
        }
    }
    Write-Output $servers
}

#Helper function for Get-DNSServers, reusable code has been placed here
function Get-DNSServersHelper()
{
        param(
            [Parameter(Mandatory=$true)][string]$computerName
        )

        $server = New-Object Servers
        $server.name = $computerName
        $networkInfo = Get-NetIPConfiguration -CimSession $computerName

        foreach ($entry in $networkInfo.dnsServer)
        {
            if ($entry.AddressFamily -eq 2) #We're only interested in the IPv4 info, AddressFamily 2 = IPv4, AddressFamily 23 = IPv6
            {
                if ($entry.ServerAddresses.count -gt 0) #Only interested in entries that actually have DNS servers, don't want to output an empty array
                {
                    $server.preferredDNSServer = $entry.ServerAddresses[0]
                    $server.alternateDNSServer = $entry.ServerAddresses[1]
                }
            }
        }

        return $server
}

function Get-HostAlive()
{
    Param(
        [Parameter(Mandatory=$true)][string]$computerName
    )

    return Test-Connection -ComputerName $computerName -BufferSize 16 -Count 1 -Quiet
}

Class Servers
{
    [string]$name
    [string]$preferredDNSServer
    [string]$alternateDNSServer
}