function Install-CustomPSModule {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Name,
    [Parameter(Mandatory = $false)]
    [string]$Scope = @('CurrentUser', 'AllUsers'),
    [Parameter(Mandatory = $false)]
    [switch]$UninstallModule
  )
  Install-Module -Name PowerShellGet -Scope $scope -Repository PsGallery -AllowClobber -Force
  Install-Module -Name PowerShellGet -Scope $scope -Repository PsGallery -AllowPrerelease -Force
  $module = $name | ForEach-Object { Get-Module -Name $_ -ListAvailable | Select-Object -First 1 }
  if (-not $module) {
    Install-PSResource -Name $Name -Repository PSGallery -TrustRepository:$true -Scope $scope -Quiet
  }
  elseif ($module | Where-Object { $_.Version -lt $module.Version }) {
    Update-PSResource -Name $module.Name -Repository PSGallery -TrustRepository:$true -Scope $scope -Quiet
  }
  else {
    Write-Host "$($module.Name) is installed"
  }
  If ($UninstallModule.IsPresent) {
    Uninstall-PSResource -Name $Name -Scope $scope -Confirm:$false
  }
}