#Readme
# To run install Azure and Remote Desktop Modules
Install-Module -Name Az -Scope CurrentUser
Install-Module -Name Microsoft.RDInfra.RDPowerShell -Scope CurrentUser

Add-RdsAccount -DeploymentUrl https://rdbroker.wvd.microsoft.com
Add-RdsAppGroupUser -TenantName 'My RDS Tenant' -HostPoolName 'MyPool' -AppGroupName 'Desktop Application Group' -UserPrincipalName joe.bloggs@contoso.com

