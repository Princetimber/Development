<#
.SYNOPSIS
  This function will get the last signInDateTime of all guest users in your tenant.
.DESCRIPTION
  This function will get the last signInDateTime of all guest users in your tenant.It will also create a csv file with the results.
.NOTES
  To use this function you need to have the Microsoft Graph PowerShell SDK installed.
  Require the following permissions: "User.Read.All", "AuditLog.Read.All", "Directory.Read.All"
    $Scopes = @("User.Read.All", "AuditLog.Read.All", "Directory.Read.All")
    Connect-MgGraph -Scopes $Scopes
.PARAMETER InactiveDays
  The number of days to check for last signInDateTime.
.PARAMETER Path
  The path where the csv file will be stored.
.PARAMETER All
  If specified, the function will get the last signInDateTime of all guest users in your tenant.
.INPUTS
  Inputs to this function (if any)
.OUTPUTS
  Outputs from this function (if any)
.LINK
  Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
  Get-MgGuestUserLastSignInDate -InactiveDays 30 -Path C:\Temp\GuestUserLastSignInDate.csv -All
  This example will get the last signInDateTime of all guest users in your tenant for the last 30 days and create a csv file with the results.
#>
Function Get-MgGuestUserLastSignInDate {
  [CmdletBinding(PositionalBinding = $false, DefaultParameterSetName = 'All')]
  Param (
    [Parameter(Mandatory = $true)][Int64]$InactiveDays,
    [Parameter(Mandatory = $true)][String]$Path,
    [Parameter(Mandatory = $true, ParameterSetName = 'All')][Switch]$All
  )
  # get the date to compare against
  $Date = [DateTime]::Now.AddDays(-$InactiveDays).ToString("yyyy-MM-ddTHH:mm:ssZ")

  # get all guest users using graph api v1.0 endpoint
  $body = @{
    filter = "userType eq 'Guest' and ExternalUserState eq 'Accepted'"
    select = "id,displayName,mail,externalUserState,externalUserStateChangeDateTime"
  } | ConvertTo-Json
  $uri = "https://graph.microsoft.com/v1.0/users"
  $Id = (Invoke-MgGraphRequest -Method GET -Uri $uri -Body $body).value.id

  # get all guest last signInDateTime using graph api v1.0 endpoint
  switch ($PSCmdlet.ParameterSetName) {
    'All' {
      foreach ($i in $Id) {
        $body = @{
          filter  = "userId eq '$i' and createdDateTime ge $Date"
          OrderBy = "createdDateTime desc"
          Top     = 1
        }
        $uri = "https://graph.microsoft.com/v1.0/auditLogs/signIns"
        $SignInDate = (Invoke-MgGraphRequest -Method GET -Uri $uri -Body $body).value
        if ($SignInDate) {
          $SignInDate | Select-Object -Property UserId, UserDisplayName, UserPrincipalname, CreatedDateTime | Export-Csv -Path $Path -Append -NoTypeInformation
        }
        elseIf ($null -eq $SignInDate) {
          Write-Output "No sign in date found for user $i">> $Path
          $SignInDate | Where-Object { $null -eq $_.CreatedDateTime } | Select-Object -Property UserId, UserDisplayName, UserPrincipalname, CreatedDateTime | Export-Csv -Path $Path -Append -NoTypeInformation
        }
      }
      Write-Output done >> $Path
    }
  }
}
