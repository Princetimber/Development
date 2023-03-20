function Install-CustomPSModule {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Name
  )
  Install-Module -Name PowerShellGet -Scope CurrentUser -Repository PsGallery -AllowClobber -Force
  $module = $name | ForEach-Object -Parallel { Get-Module -Name $_ -ListAvailable | Select-Object -First 1 }
  if (-not $module) {
    Install-PSResource -Name $Name -Repository PSGallery -TrustRepository:$true -Scope AllUsers -Quiet
  }
  elseif ($module | Where-Object { $_.Version -lt $module.Version }) {
    Update-PSResource -Name $module.Name -Repository PSGallery -TrustRepository:$true -Scope AllUsers -Quiet
  }
  else {
    Write-Host "$($module.Name) is already installed"
  }
}