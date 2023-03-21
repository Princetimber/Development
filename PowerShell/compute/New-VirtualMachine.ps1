Function New-VirtualMachine {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $true,
      Position = 0)]
    [string]$Name,
    [Parameter(Mandatory = $true, Position = 1)]
    [string]$Path,
    [Parameter(Mandatory = $false, Position = 2)]
    [string]$switchName = 'datacenter',
    [Parameter(Mandatory = $true, Position = 3)]
    [int64]$MemoryStartUpBytes
  )

  $newVHDPath = Join-Path -Path ($Path.Replace("virtualMachines", "VirtualHardDisks")) -ChildPath $VMName\"osdisk.vhdx"
  $param = @{
    name               = $name
    path               = $path
    memorystartupbytes = $memorystartupbytes
    newvhdPath         = $newvhdpath
    newvhdSizeBytes    = 60GB
    switchname         = $switchname
    generation         = 2
  }
  New-VM @param
}
function set-VMConfigurationSettings {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$VMName,
    [Parameter(Mandatory = $false, Position = 1)]
    [string]$media = @('ubuntu.iso','kali.iso','ws2k22.iso', 'w1121h2.iso'),
    [Parameter(Mandatory = $false, Position = 2)]
    [string]$mediaBinaryLocation = 'E:\Media',
    [Parameter(Mandatory = $false, Position = 3)]
    [string]$mediaPath = (Join-Path -Path $mediaBinaryLocation -ChildPath $media)
  )
  $param = @{
    VMName             = $VMName
    Path               = $mediaPath
    ControllerNumber   = 0
    ControllerLocation = 1
    Confirm            = $false
  }
  Add-VMDvdDrive @param
  $VMDvDDrive = Get-VMDvdDrive -VMName $VMName
  if ($media -match 'kali.iso' -or $media -match 'ubuntu.iso') {
    $param = @{
      VMName               = $VMName
      FirstBootDevice      = $VMDvDDrive
      EnableSecureBoot     = 'on'
      SecureBootTemplate   = 'MicrosoftUEFICertificateAuthority'
      PreferredNetworkBoot = 'IPv4'
      Confirm              = $false
    }
    Set-VMFirmware @param
  }elseif ($media -notmatch 'kali.iso' -or $media -notmatch 'ubuntu.iso') {
    $param = @{
      VMName               = $VMName
      FirstBootDevice      = $VMDvDDrive
      EnableSecureBoot     = 'on'
      SecureBootTemplate   = 'MicrosoftWindows'
      PreferredNetworkBoot = 'IPv4'
      Confirm              = $false

    }
    Set-VMFirmware @param
  }
  $param = @{
    VMName               = $VMName
    DynamicMemory        = $true
    MemoryMaximumBytes   = 8200MB
    MemoryMinimumBytes   = 4100MB
    MemoryStartUpBytes   = 4100MB
    AutomaticStartAction = 'Nothing'
    AutomaticStopAction  = 'Shutdown'
    LockOnDisconnect     = 'on'
  }
  Set-VM @param
  $param = @{
    VMName                           = $VMName
    Count                            = 2
    Reserve                          = 50
    RelativeWeight                   = 100
    CompatibilityForMigrationEnabled = $true
    Confirm                          = $false
  }
  Set-VMProcessor @param
  $param = @{
    VMName            = $VMName
    DynamicMacAddress = $true
    DeviceNaming      = 'on'
    DhcpGuard         = 'on'
    RouterGuard       = 'on'
    VmmqEnabled       = $true
    VrssEnabled       = $true
    AllowTeaming      = 'on'
  }
  Set-VMNetworkAdapter @param
  Enable-VMConsoleSupport -VMName $VMName
  $param = @{
    VMName               = $VMName
    NewLocalKeyProtector = $true
    Confirm              = $false
  }
  Set-VMKeyProtector @param
  Enable-VMTPM -VMName $VMName
  $param = @{
    VMName                            = $VMName
    EncryptStateAndVMMigrationTraffic = $true
    VirtualizationBasedSecurityOptOut = $false
    Confirm                           = $false
  }
  Set-VMSecurity @param
}
