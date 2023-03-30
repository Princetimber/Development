<#
.SYNOPSIS
  Adds or removes a device tag for Microsoft Defender for Endpoint
.DESCRIPTION
  Adds or removes a device tag for Microsoft Defender for Endpoint
.NOTES
  Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
  Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
  Set-MDEDevicetag -Path 'HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\DeviceTagging' -Name 'Group' -Value 'Test'
  Adds a device tag to the device
.EXAMPLE
  Set-MDEDevicetag -RemoveTag
  Removes the device tag from the device
.EXAMPLE
  Set-MDEDevicetag -ResetTag
  Resets the device tag to the current OU
.PARAMETER Path
  The path to the registry . Default value is 'HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\DeviceTagging'
.PARAMETER Name
  The name of the registry key. Default value is 'Group'
.PARAMETER Value
  The value of the registry key. Default value is set to the value of the OU of the device
.PARAMETER ResetTag
  Resets the device tag to the current OU.
  If the current OU is different from the device tag, the device tag will be reset to the current OU
.PARAMETER RemoveTag
  Removes the device tag from the device.
  This will also remove the registry key.
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][string]$Path,
  [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][string]$Name,
  [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 2)][switch]$ResetTag,
  [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 3)][switch]$RemoveTag
)
$DN = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine' -Name Distinguished-Name)."Distinguished-Name"
$Value = $DN.SubString($DN.IndexOf("OU="))
$Path = 'HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\DeviceTagging'
$Name = 'Group'
if (!(Test-Path $Path)) {
  New-Item -Path $Path -Force | Out-Null
  Set-ItemProperty -Path $Path -Name $Name -Value $Value
}
ElseIf ($RemoveTag.IsPresent) {
  Remove-ItemProperty -Path $Path -Name $Name -Force | Out-Null
  Remove-Item -Path $Path -Force | Out-Null
}
Else {
  Set-ItemProperty -Path $Path -Name $Name -Value $Value
}

if ($ResetTag.IsPresent -and $Value -ne (Get-ItemProperty -Path $Path -Name $Name)."Group") {
  Remove-ItemProperty -Path $Path -Name $Name -Force | Out-Null
  Remove-Item -Path $Path -Force | Out-Null
  New-Item -Path $Path -Force | Out-Null
  Set-ItemProperty -Path $Path -Name $Name -Value $Value
}
elseif ($ResetTag.IsPresent -and !(Test-Path $Path)) {
  New-Item -Path $Path -Force | Out-Null
  Set-ItemProperty -Path $Path -Name $Name -Value $Value
}
else {
  Set-ItemProperty -Path $Path -Name $Name -Value $Value
}