Connect-AzAccount
#Get the name of the custom role
$FileShareContributorRole = Get-AzRoleDefinition "AFReadWriteRole" #Use one of the built-in roles: Storage File Data SMB Share Reader, Storage File Data SMB Share Contributor, Storage File Data SMB Share Elevated Contributor
#Constrain the scope to the target file share
$scope = "/subscriptions/cabd9ac3-fda5-4173-a7f8-c29c14537c89/resourceGroups/WVD/providers/Microsoft.Storage/storageAccounts/wvd01/fileServices/default/fileshares/users"
#Assign the custom role to the target identity with the specified scope.
New-AzRoleAssignment -SignInName joe.bloggs@contoso.com -RoleDefinitionName $FileShareContributorRole.Name -Scope $scope
