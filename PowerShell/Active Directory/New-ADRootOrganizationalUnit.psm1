function New-ADRootOrganizationalUnit {
  [CmdletBinding(DefaultParameterSetName = 'Create', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
  param (
    [Parameter(Mandatory = $true, ParameterSetName = 'Create')][switch]$Create,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][ValidateScript(
      {
        if (-not(Get-ADOrganizationalUnit -Filter { Name -eq $Name } -ErrorAction SilentlyContinue)) {
          $true
        }
        else {
          throw "An organizational unit with the name '$($_)' already exists."
        }
      }
    )][string]$Name,
    [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][string]$Path = "DC=Intheclouds365,DC=com"
  )
  #validate Name parameter is not null or empty
  if ([string]::IsNullOrEmpty($Name)) {
    throw "The name of the organizational unit cannot be null or empty."
  }
  #validate Path parameter is not null or empty
  if ([string]::IsNullOrEmpty($Path)) {
    throw "The path of the organizational unit cannot be null or empty."
  }
  #create the organizational unit
  switch ($PSCmdlet.ParameterSetName) {
    "Create" {
      if ($PSCmdlet.ShouldProcess($Name, 'Create Organizational Unit')) {
        New-ADOrganizationalUnit -Name $Name -Path $Path -ProtectedFromAccidentalDeletion $true
      }
      elseIf ($PSCmdlet.ShouldContinue("Do you want to create the organizational unit '$Name'?", 'Create Organizational Unit')) {
        New-ADOrganizationalUnit -Name $Name -Path $Path -ProtectedFromAccidentalDeletion $true
      }
    }
  }
}