[CmdletBinding(DefaultParameterSetName = 'Remove')]
Param(
  [Parameter(Mandatory = $true)][string]$Name,
  [Parameter(Mandatory = $true, ParameterSetName = 'Remove')][switch]$Remove
)
switch ($PSCmdlet.ParameterSetName) {
  'Remove' {
    $feature = Get-WindowsFeature -Name $Name -ErrorAction SilentlyContinue
    if($feature.Installed -eq $true) {
      uninstall-WindowsFeature -Name $Name -Remove
    }
    else {
      Write-Warning "The feature '$Name' is not installed."
    }
  }
}