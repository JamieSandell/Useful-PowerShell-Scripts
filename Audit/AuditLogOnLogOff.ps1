$todaysDate = Get-Date
$startDate = $todaysDate.AddDays(-7) #last 7 days

$machine = "DomainController01" #where we are querying the events from

$filter = @{LogName='ForwardedEvents';
            StartTime=$startDate;
            EndTime=$todaysDate}

$savePath = "C:\temp\"
$saveFile = $todaysDate.ToString()
$saveFile = $saveFile -replace "/", "." #Needs to be in a valid name format for saving
$saveFile = $saveFile -replace ":", "." #Needs to be in a valid name format for saving
$saveFile = $saveFile + ".csv"
$outFile = $savePath + $saveFile

$eventLog = Get-WinEvent -FilterHashtable $filter -ComputerName $machine #get the events from the machine based on our filter
$events = @() #array of objects
foreach ($event in $eventLog) #cycle through the event log, create an object based on whether it was a logon or logoff event.
#Add each object to the array of objects (events).
{
    if ($event.Id -eq 4624) #A Logon event
    {
        $object = New-Object -TypeName PSObject -Property @{
            MachineName = $event.Properties[1].Value
            Username = $event.Properties[5].Value
            Event = "Logon"
            DateAndTime = $event.TimeCreated
        }        
    }
    elseif ($event.Id -eq 4647) #A Logoff event
    {
        $object = New-Object -TypeName PSObject -Property @{
            MachineName = "Not logged by this event"
            Username = $event.Properties[1].Value
            Event = "Logoff"
            DateAndTime = $event.TimeCreated
         }
    }
    $object.MachineName = $object.MachineName.TrimEnd("$") #Remove the $ from the end of the machine name
    $events += $object
}
$events | Export-Csv $outFile -NoTypeInformation #Output our logon and logoff events to a CSV file.