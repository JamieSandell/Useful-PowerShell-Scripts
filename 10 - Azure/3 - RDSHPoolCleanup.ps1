Add-RdsAccount -DeploymentUrl https://rdbroker.wvd.microsoft.com
$tenant = 'My RDS Tenant'
$hostPoolName = 'PoolName'
Get-RdsAppGroup -TenantName $tenant -HostPoolName $hostPoolName
Get-RdsAppGroupUser -TenantName $tenant -HostPoolName $hostPoolName -AppGroupName "Remote App Group"
Get-RdsAppGroup -TenantName $tenant -HostPoolName $hostPoolName | Remove-RdsAppGroup
Get-RdsHostPool -TenantName $tenant
Get-RdsSessionHost -TenantName $tenant -HostPoolName $hostPoolName
Get-RdsSessionHost -TenantName $tenant -HostPoolName $hostPoolName | Remove-RdsSessionHost
Get-RdsHostPool -TenantName $tenant | Remove-RdsHostPool