$PGroups = Get-DPMProtectionGroup | where {$_.Name -like '*'}; $PGroups

foreach ($PGroup in $PGroups)
{
    $PObjects = Get-DPMDatasource -ProtectionGroup $PGroup | where {$_.Name -like '*'}; $PObjects
    foreach ($PObject in $PObjects)
    {
        $RPoint = Get-DPMRecoveryPoint -Datasource $PObject | select -Last 1; $RPoint
        Remove-DPMRecoveryPoint -RecoveryPoint $RPoint -Confirm:$false
    }
    
}

