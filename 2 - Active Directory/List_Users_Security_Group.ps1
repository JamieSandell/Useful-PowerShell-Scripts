$User =  Read-Host -Prompt 'Please input the user that you would like to query'
Get-ADPrincipalGroupMembership -identity $User | Select Name | Export-CSV ".\UserSecurityGroup.csv" -NoTypeInformation