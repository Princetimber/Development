function New-ADSecurityGroup {
  [CmdletBinding(DefaultParameterSetName = 'Create', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidateScript({
        if (-not(Get-ADGroup -Identity $_ -ErrorAction SilentlyContinue)) {
          $true
        }
        else {
          throw "A group with the name '$($_)' already exists."
        }
      })][string]$Name,
    [Parameter(Mandatory = $true, Position = 1)][ValidateSet('Domainlocal', 'Global', 'Universal  ')][string]$Scope,
    [Parameter (Mandatory = $true, Position = 2)][ValidateSet('Security', 'Distribution')][string]$Category,
    [Parameter(Mandatory = $true, Position = 3)][ValidateScript()][string]$Path,
    [Parameter(Mandatory = $false, Position = 4, ParameterSetName = 'Create')][switch]$Create
  )
  #validate Name parameter is not null or empty
  if ([string]::IsNullOrEmpty($Name)) {
    throw "The name of the group cannot be null or empty."
  }
  #validate Path parameter is not null or empty
  if ([string]::IsNullOrEmpty($Path)) {
    throw "The path of the group cannot be null or empty."
  }
  # create the group
  switch ($PSCmdlet.ParameterSetName) {
    "create" {
      if ($PSCmdlet.ShouldProcess($Name, 'Create group')) {
        New-ADGroup -Name $Name -Path $Path -GroupScope $Scope -GroupCategory $Category
      }
      elseif ($PSCmdlet.ShouldContinue("Do you want to create the group '$Name' in the path '$Path'?", 'Create group')) {
        New-ADGroup -Name $Name -Path $Path -GroupScope $Scope -GroupCategory $Category
      }
    }
  }
}
function Update-ADPrincipalGroupMembership {
  [CmdletBinding(DefaultParameterSetName = 'Add', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidateScript({
        if (Get-ADGroup -Identity $_ -ErrorAction SilentlyContinue) {
          $true
        }
        else {
          throw "A group with the name '$($_)' does not exist."
        }
      })][string]$GroupName,
    [Parameter(Mandatory = $true, ParameterSetName = 'Add')][switch]$Add
  )
  #validate Name parameter is not null or empty
  if ([string]::IsNullOrEmpty($GroupName)) {
    throw "The name of the group cannot be null or empty."
  }
  # get the distinguished name of the groups security principals
  $securityDN = @('Domain Admins', 'Enterprise Admins', 'Group Policy Creator Owners', 'Schema Admins')
  $memberOf = $securityDN | ForEach-Object {
    Get-ADGroup -Identity $_ | Select-Object -Property DistinguishedName
  }
  # get the distinguished name of the group
  $Identity = Get-ADGroup -Identity $GroupName | Select-Object -Property DistinguishedName
  # add the security principals to the group
  switch ($PSCmdlet.ParameterSetName) {
    "Add" {
      if ($PSCmdlet.ShouldProcess($GroupName, 'Add security principals to group')) {
        Add-ADPrincipalGroupMembership -Identity $Identity -MemberOf $memberOf
      }
      elseif ($PSCmdlet.ShouldContinue("Do you want to add the security principals to the group '$GroupName'?", 'Add security principals to group')) {
        Add-ADPrincipalGroupMembership -Identity $Identity -MemberOf $memberOf
      }
    }
  }
}