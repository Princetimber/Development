<#
.SYNOPSIS
  This function will install a custom PSModule from the PSGallery.
  It will also update the module if a newer version is available.
  It will also uninstall the module if the -Uninstall switch is used.
.DESCRIPTION
  This function will install a list of PSResources from the PSGallery.
  It will also update the PSResource if a newer version is available when the -Update switch is used.
  It will also uninstall the module if the -Uninstall switch is used.
.NOTES
  Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
  Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
  Install-CustomPSModule -Name 'Az' -Scope 'CurrentUser'
  This will install the Az module from the PSGallery.
.EXAMPLE
  Install-CustomPSModule -Name 'Az' -Scope 'CurrentUser' -Uninstall
  This will uninstall the Az module from the PSGallery.
.PARAMETER Name
  The name of the module to install.
.PARAMETER Scope
  The scope of the module to install.  This can be either 'CurrentUser' or 'AllUsers'.
  The default is 'CurrentUser'.
.PARAMETER Uninstall
  This switch will uninstall the module if it is already installed.
.PARAMETER Update
  This switch will update the module if a newer version is available.
#>

function Install-CustomPSModule {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true,HelpMessage = "Enter the name(s) of the PSResource")][ValidateNotNullOrEmpty][string]$Name,
    [Parameter(Mandatory = $false, Position = 1, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)][ValidateSet('CurrentUser', 'AllUsers')][string]$Scope = 'CurrentUser',
    [Parameter(Mandatory = $false, Position = 2, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)][switch]$Uninstall,
    [Parameter(Mandatory = $false, Position = 3, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)][switch]$Update
  )
  if([string]::IsNullOrEmpty($Name)) {
    throw "The Name parameter is required and cannot be null or empty."
  }
  # Install the PowerShellGet module
  Install-Module -Name PowerShellGet -Scope $scope -Repository PsGallery -AllowClobber -Force
  Install-Module -Name PowerShellGet -Scope $scope -Repository PsGallery -AllowPrerelease -Force
  # validate if the module is already installed
  $module = $name | ForEach-Object { Get-Module -Name $_ -ListAvailable | Select-Object -First 1 }
  if (-not $module) {
    Write-Host "Installing..."
    Install-PSResource -Name $Name -Repository PSGallery -TrustRepository:$true -Scope $scope -Quiet
    Write-Host "PSResource $($module.Name) is now installed"
  }
  elseif ($Update.IsPresent -and $module | Where-Object { $_.Version -lt $module.Version }) {
    Write-Host "Updating..."
    Update-PSResource -Name $module.Name -Repository PSGallery -TrustRepository:$true -Scope $scope -Quiet
    Write-Host "The PSResource $($module.Name) is now updated"
  }
  elseIf ($Uninstall.IsPresent) {
    Write-Host "Uninstalling..."
    Uninstall-PSResource -Name $Name -Scope $scope -Confirm:$false
    Write-Host "PSResource $($module.Name) is now uninstalled"
  }
}