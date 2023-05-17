<#
.SYNOPSIS
  This function will activate Windows.
.DESCRIPTION
  This function will check if Windows is activated and activate Windows if it is not activated.
.NOTES
  Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
  Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
  add-ProductKey -Status
  This will check if Windows is activated.
  Parameter -Status is mandatory.
  This will return a message if Windows is activated or not.
  This is useful to check if Windows is activated before running the function.
.EXAMPLE
  add-ProductKey -Activate
  This will activate Windows.
  Parameter -Activate is mandatory.
  This will return a message if Windows is activated or not.
  This is useful to check if Windows is activated before running the function.
#>

function Add-ProductKey {
  [cmdletbinding()]
  Param(
    [Parameter(Mandatory = $false, Position = 0)][switch]$Status,
    [Parameter(Mandatory = $false, Position = 1)][switch]$Activate,
    [Parameter(Mandatory = $false, Position = 2, HelpMessage = "enter windows product activation key.")][string]$ActivationKey
  )
  $ProductKey = (Get-CimInstance -Query "SELECT * FROM SoftwareLicensingService").OA3xOriginalProductKey
  $LicenseStatus = (Get-CimInstance -ClassName SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL" | Where-Object Name -Like Windows*).LicenseStatus
  if ($Status.IsPresent -and $LicenseStatus -eq 1) {
    Write-Host "Windows is already activated!"
  }
  elseIf ($Status.IsPresent -and $LicenseStatus -ne 1) {
    Write-Host "Activating Windows..."
    Start-Process -FilePath C:\Windows\System32\changepk.exe -ArgumentList "/productkey:$ProductKey" -Wait
    Write-Host "Windows is now activated!"
  }
  elseIf ($Activate.IsPresent -and $LicenseStatus -ne 1) {
    Write-Host "Activating Windows..."
    Start-Process -FilePath C:\Windows\System32\changepk.exe -ArgumentList "/productkey:$ActivationKey" -Wait
    Write-Host "Windows is now activated using the productkey provided.!"
  }
}