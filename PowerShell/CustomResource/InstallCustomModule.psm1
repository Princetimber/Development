  <#
.SYNOPSIS
  This function installs a custom module from the PowerShell Gallery
.DESCRIPTION
  This function installs a custom module from the PowerShell Gallery
.NOTES
  Information or caveats about the function e.g. 'This function is not supported in Linux'.
.PARAMETER Name
  The name of the module to be installed. This is a mandatory parameter
.PARAMETER Install
  Switch to install the module. This will only install the module if it is not already installed
.PARAMETER Uninstall
  Switch to uninstall the module. This will only uninstall the module if it is already installed
.PARAMETER Update
  Switch to update the module. This will only update the module if it is already installed
.PARAMETER Scope
  The scope of the module to be installed. This can either be AllUsers or CurrentUser
.LINK
  Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
  install-CustomModule -Name 'MyModule' -Install -Scope 'AllUsers'
  This example will install the module MyModule from the PowerShell Gallery for all users
.EXAMPLE
  install-CustomModule -Name 'MyModule' -Uninstall -Scope 'AllUsers'
  This example will uninstall the module MyModule from the PowerShell Gallery for all users
.EXAMPLE
  install-CustomModule -Name 'MyModule' -Update -Scope 'AllUsers'
  This example will update the module MyModule from the PowerShell Gallery for all users
.INPUTS
  Inputs to the function (if any)
.OUTPUTS
  Outputs from the function (if any)
#>
function install-CustomModule {
  [CmdletBinding(DefaultParameterSetName = 'Install')]
  param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = 'Name of module to be installed')][ValidateNotNullOrEmpty()][string]$Name,
    [Parameter(Mandatory = $false, ParameterSetName = 'Install', Position = 1, HelpMessage = 'Install switch')][switch]$Install,
    [Parameter(Mandatory = $false, ParameterSetName = 'Uninstall', Position = 2, HelpMessage = 'Uninstall switch')][switch]$Uninstall,
    [Parameter(Mandatory = $false, ParameterSetName = 'Update', Position = 3, HelpMessage = 'Update switch')][switch]$Update,
    [Parameter(Mandatory = $true, Position = 4)][ValidateSet('AllUsers', 'CurrentUser')][string]$Scope
  )
  #check that name is not null or empty
  if ([string]::IsNullOrEmpty($Name)) {
    throw 'Name cannot be null or empty'
  }
  #Install PowwerShellGet if not installed
  if (-not(Get-Module -Name PowerShellGet -ListAvailable)) {
    Install-Module -Name PowerShellGet -Repository PSGallery -Scope $Scope -AllowClobber -Force
    Install-Module -Name PowerShellGet -Repository PSGallery -Scope $Scope -AllowPrerelease -Force
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
  }
  #Install module
  $module = Get-Module -Name $Name -ListAvailable -ErrorAction SilentlyContinue
  switch ($PSCmdlet.ParameterSetName) {
    'install' {
      if (!$module) {
        Install-PSResource -Name $Name -Repository PSGallery -Scope $Scope -TrustRepository:$true -Quiet -Confirm:$false
      }
    }
    'uninstall' {
      if ($module) {
        Uninstall-PSResource -Name $Name -Scope $Scope -Confirm:$false
      }
    }
    'update' {
      if ($module) {
        Update-PSResource -Name $Name -Repository PSGallery -Scope $Scope -TrustRepository:$true -Quiet -Confirm:$false
      }
    }
  }
}