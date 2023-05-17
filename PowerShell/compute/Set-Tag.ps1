<#
.SYNOPSIS
  Adds or removes a device tag for Microsoft Defender for Endpoint
.DESCRIPTION
  Adds or removes a device tag for Microsoft Defender for Endpoint.
  The device tag is set to the value of the OU of the device, which can be used by organizations with multiple OUs to tag devices in Microsoft Defender for Endpoint.
  The device tag is set in the registry key 'HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\DeviceTagging'.
.NOTES
  Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
  Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
  Set-Tag -Tag
  Adds a device tag to the device
.EXAMPLE
  Set-Tag -ResetTag
  Resets the device tag to the current OU.
  If the current OU is different from the device tag, the device tag will be reset to the current OU
.EXAMPLE
  Set-Tag -RemoveTag
  Removes the device tag from the device.
  This will also remove the registry key.
.PARAMETER Tag
  Adds a device tag to the device
.PARAMETER ResetTag
  Resets the device tag to the current OU.
  If the current OU is different from the device tag, the device tag will be reset to the current OU
.PARAMETER RemoveTag
  Removes the device tag from the device.
  This will also remove the registry key.
#>
function Set-Tag {
  [CmdletBinding(DefaultParameterSetName = 'Tag', PositionalBinding = $true)]
  param(
    [Parameter(ParameterSetName = 'Tag', Mandatory, Position = 0)][switch]$Tag,
    [Parameter(ParameterSetName = 'ResetTag', Mandatory, Position = 1)][Switch]$ResetTag,
    [Parameter(ParameterSetName = 'RemoveTag', Mandatory, Position = 2)][Switch]$RemoveTag
  )
  Set-StrictMode -Version 2.0
  $DistinguishedName = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine' -Name 'Distinguished-Name')."Distinguished-Name"
  $regValue = $DistinguishedName.SubString($DistinguishedName.IndexOf("OU=")) | ForEach-Object { $_.Split(",") } | Select-Object -First 2 | ForEach-Object { $_.Split("=") } | Select-Object -Last 1
  $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\DeviceTagging'
  $Name = 'Group'
  switch ($PSCmdlet.ParameterSetName) {
    'Tag' {
      if (!(Test-Path -Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
        Set-ItemProperty -Path $regPath -Name $Name -Value $regValue
      }
      break
    }
    'ResetTag' {
      $CurrentValue = Get-ItemProperty -Path $regPath -Name $Name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $Name
      if (!((Test-Path -Path $regPath) -and (Test-Path -Path $regPath -PathType Leaf))) {
        New-Item -Path $regPath -Force | Out-Null
        Set-ItemProperty -Path $regPath -Name $Name -Value $regValue
      } elseIf ($CurrentValue -ne $regValue) {
        Remove-ItemProperty -Path $regPath -Name $Name -Force | Out-Null
        Set-ItemProperty -Path $regPath -Name $Name -Value $regValue
      } elseIf ($null -eq $CurrentValue) {
        New-Item -Path $regPath -Force | Out-Null
        Set-ItemProperty -Path $regPath -Name $Name -Value $regValue
      } else {
        Write-Information -MessageData "Device tag is already set to the current OU."
      }
      break
    }
    'RemoveTag' {
      if ((Test-Path -Path $regPath -PathType Container)) {
        Remove-ItemProperty -Path $regPath -Name $Name -Force
        Remove-Item -Path $regPath -Force
      }
      break
   }
  }
}