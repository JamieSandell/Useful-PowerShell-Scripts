$PG = Get-DPMProtectionGroup | where {$_.FriendlyName -eq "Virtual Servers" }
Write-host "Protection Group:"
$PG|fl

$ds = Get-DPMDatasource $PG | where { $_.Computer -eq "gbyor-vsfs6" }

Write-host "Datasource:"
$ds|fl
Write-host "ReplicaUsedSpace: $($ds.ReplicaUsedSpace)"
Write-host "ReplicaSize: $($ds.ReplicaSize)"

$sz = $ds.ReplicaSize
"Old size: ", $sz
$sz += 500GB
"New size: ", $sz
$sz1 = 40GB

Edit-DPMDiskAllocation -Datasource $ds -ReplicaSize $sz -ShadowCopySize $sz1