function New-ADChildOrganizationalUnit {
  [CmdletBinding(DefaultParameterSetName = 'Create', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Create')][switch]$Create,
    [Parameter(Mandatory = $true, Position = 0,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $true)][ValidateNotNullOrEmpty()][ValidateScript({
        if (-not(Get-ADOrganizationalUnit -Name $_ -ErrorAction SilentlyContinue)) {
          $true
        }
        else {
          throw "An Organizational Unit with the name '$($_)' already exists."
        }
      })][string]$Name,
    [Parameter(Mandatory = $false, Position = 1)][ValidateNotNullOrEmpty()][string]$Path
  )
  #validate Name parameter is not null or empty
  if ([string]::IsNullOrEmpty($Name)) {
    throw "The name of the Organizational Unit cannot be null or empty."
  }
  #validate Path parameter is not null or empty
  if ([string]::IsNullOrEmpty($Path)) {
    throw "The path of the Organizational Unit cannot be null or empty."
  }
  # create the Organizational Unit
  switch ($PSCmdlet.ParameterSetName) {
    "Create" {
      if ($PSCmdlet.ShouldProcess($Name, 'Create Child Organizational Unit')) {
        New-ADOrganizationalUnit -Name $Name -Path $Path
      }
      elseif ($PSCmdlet.ShouldContinue("Do you want to create the Organizational Unit '$Name' in the path '$Path'?", 'Create Child Organizational Unit')) {
        New-ADOrganizationalUnit -Name $Name -Path $Path
      }
    }
  }
}