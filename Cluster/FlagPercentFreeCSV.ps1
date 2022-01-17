Import-Module -Name '..\powershell modules\Email.psm1'

#Cluster objects
$LANCluster1 = New-Object PSObject -Property @{
    Name = 'Cluster01'
    Node01 = 'Node01'
    Node02 = 'Node02'
    Node01Alive = $true
    Node02Alive = $true    
}
$LANCluster2 = New-Object PSObject -Property @{
    Name = 'Cluster02'
    Node01 = 'Node01'
    Node02 = 'Node02'
    Node01Alive = $true
    Node02Alive = $true  
}

$clusters = @($LANCluster1, $LANCluster2)

#Go through each cluster, and check both nodes to see if they are online.
#Don't want to run commands on/against offline machines
foreach ($cluster in $clusters)
{
    if (Test-Connection -ComputerName $cluster.Node01 -Count 1)
    {
        $cluster.Node01Alive = $true
    }
    else
    {
        $cluster.Node01Alive = $false
    }

    if (Test-Connection -ComputerName $cluster.Node02 -Count 1)
    {
        $cluster.Node02Alive = $true
    }
    else
    {
        $cluster.Node02Alive = $false
    }
}

#Script block to be executed on one node from each cluster remotely
#Gets the cluster storage volume info
$scriptBlock = {
    Import-Module FailoverClusters
    $objs = @()
    $csvs = Get-ClusterSharedVolume
    foreach ( $csv in $csvs )
    {
       $csvinfos = $csv | select -Property Name -ExpandProperty SharedVolumeInfo
       foreach ( $csvinfo in $csvinfos )
       {
          $obj = New-Object PSObject -Property @{
             Name        = $csv.Name
             Path        = $csvinfo.FriendlyVolumeName
             Size        = ($csvinfo.Partition.Size / 1024 / 1024 / 1024) #Convert size to GB
             FreeSpace   = ($csvinfo.Partition.FreeSpace / 1024 / 1024 / 1024)
             UsedSpace   = ($csvinfo.Partition.UsedSpace / 1024 / 1024 / 1024)
             PercentFree = $csvinfo.Partition.PercentFree
            }
            $objs += $obj
        }
    }
    return $objs

}

#Cycle each cluster and run the script block on one node from each.
$objs = @()
foreach ($cluster in $clusters)
{
    if ($cluster.Node01Alive) #First node alive?
    {
        $objs += Invoke-Command -ComputerName $cluster.Node01 -ScriptBlock $scriptBlock
    }
    elseif($cluster.Node02Alive) #Second node isn't alive/down for maintenance, so try the second node
    {
        $objs += Invoke-Command -ComputerName $cluster.Node02 -ScriptBlock $scriptBlock
    }
    else #no node was alive on the cluster so can't query CSV storage
    {
        Write-Output "No node from cluster $($cluster.Name) is online"
    }
    
}

#Cycle through each CSV data found, if the percentage free is below 10%, send an e-mail to the Helpdesk
foreach ($csv in $objs)
{
    if ($csv.PercentFree -lt 10)
    { 
        $smtpFrom = "proactive@contoso.com"  
        $smtpTo = "helpdesk@contoso.com" 
        $smtpSubject = "CSV '$($csv.Name)' has less than 10% free space"
        $smtpBody = ""
        #$smtpBody = $csv.Split([Environment]::NewLine)
        foreach ($property in $csv.PSObject.Properties)
        {
            $smtpBody += $property.Name + "`t:`t" + $property.Value + "`r`n"
        }

        Send-MailMessage -To $smtpTo -From $smtpFrom -Subject $smtpSubject -Body $smtpBody
    }
}

Remove-Module -Name Email