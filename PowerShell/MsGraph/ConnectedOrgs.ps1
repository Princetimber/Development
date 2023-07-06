$scope = @("EntitlementManagement.Read.All")
Connect-MgGraph -Scopes $scope

$DisplayNames = Get-MgEntitlementManagementConnectedOrganization -All | Select-Object -Property DisplayName
$azureadOrganizations = @()
$otherOrganizations = @()
foreach ($DisplayName in $DisplayNames) {
  if ($DisplayName -like "*AzureAD*") {
    $tenantId = $DisplayName.DisplayName.Substring($DisplayName.DisplayName.IndexOf("ConOrg-")) | ForEach-Object { $_.Split(",") } | Select-Object -First 2 | ForEach-Object { $_.Split("-") } | Select-Object -Last 5 | Join-String -Separator "-"
    $MemberID = $DisplayName.DisplayName.Substring($DisplayName.DisplayName.IndexOf("ConOrg-")) | ForEach-Object { $_.Split(",") } | Select-Object -First 2 | ForEach-Object { $_.Split("-") } | Select-Object -Skip 1 -First 1
    $azureadOrganizations += [PSCustomObject]@{
      DisplayName = $DisplayName.DisplayName
      TenantId    = $tenantId
      MemberID    = $MemberID
    }
  }
  elseIf ($DisplayName -like "*EmailOTP*") {
    $MemberID = $DisplayName.DisplayName.Substring($DisplayName.DisplayName.IndexOf("ConOrg-")) | ForEach-Object { $_.Split(",") } | Select-Object -First 2 | ForEach-Object { $_.Split("-") } | Select-Object -Skip 1 -First 1
    $otherOrganizations += [PSCustomObject]@{
      DisplayName = $DisplayName.DisplayName
      MemberID    = $MemberID
    }
  }
}
$azureadOrganizations | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath "~/Documents/azuread.csv" -Encoding UTF8 -Force
$otherOrganizations | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath "~/Documents/other.csv" -Encoding UTF8 -Force
