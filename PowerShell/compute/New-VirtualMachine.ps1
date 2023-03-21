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
    [string]$media = @('ubuntu.iso', 'kali.iso', 'ws2k22.iso', 'w1121h2.iso'),
    [Parameter(Mandatory = $false, Position = 2)]
    [string]$mediaBinaryLocation = 'E:\Media',
    [Parameter(Mandatory = $false, Position = 3)]
    [string]$mediaPath = (Join-Path -Path $mediaBinaryLocation -ChildPath $media),
    [Parameter(Mandatory = $false, Position = 4)]
    [switch]$AddDCSetting,
    [Parameter(Mandatory = $false, Position = 5)]
    [switch]$AddConfigMgrSetting

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
  }
  elseif ($media -notmatch 'kali.iso' -or $media -notmatch 'ubuntu.iso') {
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
  if ($AddDCSetting.IsPresent) {
    $ChildPaths = @('logs.vhdx', 'sysvol.vhdx', 'ntds.vhdx')
    $newVHDPath = $ChildPaths | ForEach-Object { Join-Path -Path ($Path.Replace("virtualMachines", "VirtualHardDisks")) -ChildPath $VMName\"$_" }
    $NewVHDPath | ForEach-Object {
      $param = @{
        Path      = $_
        SizeBytes = 30GB
        Dynamic   = $false
        Confirm   = $false
      }
      New-VHD @param
    }
    if ($ChildPaths -match 'logs.vhdx') {
      $param = @{
        VMName             = $VMName
        Path               = $newVHDPath[0]
        ControllerType     = 'iscsi'
        ControllerNumber   = 0
        ControllerLocation = 2
        Confirm            = $false
      }
      Add-VMHardDiskDrive @param
    }
    if ($ChildPaths -match 'sysvol.vhdx') {
      $param = @{
        VMName             = $VMName
        Path               = $newVHDPath[1]
        ControllerType     = 'iscsi'
        ControllerNumber   = 0
        ControllerLocation = 3
        Confirm            = $false
      }
      Add-VMHardDiskDrive @param
    }
    if ($ChildPaths -match 'ntds.vhdx') {
      $param = @{
        VMName             = $VMName
        Path               = $newVHDPath[2]
        ControllerType     = 'iscsi'
        ControllerNumber   = 0
        ControllerLocation = 4
        Confirm            = $false
      }
      Add-VMHardDiskDrive @param
    }
  }
  else {
    Write-Output "[system.DateTime]::Now - VM $VMName has been created without the DC settings"
    Write-Output "[system.DateTime]::Now - [INFO] - To add the DC Settings, please run the following command: Set-VMConfigurationSettings -VMName $VMName -AddDCSetting"
  }
  if ($AddConfigMgrSetting.IsPresent) {
    $param = @{
      VMName                       = $VMName
      StaticMemory                 = $true
      MemoryStartUpBytes           = 32800MB
      AutomaticStartAction         = 'Start'
      AutomaticStopAction          = 'Shutdown'
      AutomaticStartDelay          = 90
      AutomaticCriticalErrorAction = 90
      LockOnDisconnect             = 'on'
    }
    Set-VM @param
    $param = @{
      VMName                           = $VMName
      Count                            = 4
      Reserve                          = 50
      RelativeWeight                   = 100
      CompatibilityForMigrationEnabled = $true
      Confirm                          = $false
    }
    Set-VMProcessor @param
    $ChildPath = @('logs.vhdx', 'mdf.vhdx', 'ldf.vhdx', 'contentLibrary.vhdx', 'temp.vhdx', 'ConfigMgrInstall.vhdx')
    if ($childPath -match 'logs.vhdx') {
      $path = Join-Path -Path $Path.Replace("virtualMachines", "VirtualHardDisks") -ChildPath $VMName\logs.vhdx
      $param = @{
        Path      = $path
        SizeBytes = 50GB
        Dynamic   = $false
        Confirm   = $false
      }
      New-VHD @param
      $param = @{
        VMName             = $VMName
        Path               = $path
        ControllerType     = 'iscsi'
        ControllerNumber   = 0
        ControllerLocation = 2
        Confirm            = $false
      }
      Add-VMHardDiskDrive @param
    }
    if ($childPath -match 'mdf.vhdx') {
      $path = Join-Path -Path $Path.Replace("virtualMachines", "VirtualHardDisks") -ChildPath $VMName\'mdf.vhdx'
      $param = @{
        Path      = $path
        SizeBytes = 75GB
        Dynamic   = $false
        Confirm   = $false
      }
      New-VHD @param
      $param = @{
        VMName             = $VMName
        Path               = $path
        ControllerType     = 'iscsi'
        ControllerNumber   = 0
        ControllerLocation = 3
        Confirm            = $false
      }
      Add-VMHardDiskDrive @param
    }
    if ($childPath -match 'ldf.vhdx') {
      $path = Join-Path -Path $Path.Replace("virtualMachines", "VirtualHardDisks") -ChildPath $VMName\'ldf.vhdx'
      $param = @{
        Path      = $path
        SizeBytes = 25GB
        Dynamic   = $false
        Confirm   = $false
      }
      New-VHD @param
      $param = @{
        VMName             = $VMName
        Path               = $path
        ControllerType     = 'iscsi'
        ControllerNumber   = 0
        ControllerLocation = 4
        Confirm            = $false
      }
      Add-VMHardDiskDrive @param
    }
    if ($childPath -match 'contentLibrary.vhdx') {
      $path = Join-Path -Path $Path.Replace("virtualMachines", "VirtualHardDisks") -ChildPath $VMName\'contentLibrary.vhdx'
      $param = @{
        Path      = $path
        SizeBytes = 500GB
        Dynamic   = $true
        Confirm   = $false
      }
      New-VHD @param
      $param = @{
        VMName             = $VMName
        Path               = $path
        ControllerType     = 'iscsi'
        ControllerNumber   = 0
        ControllerLocation = 5
        Confirm            = $false
      }
      Add-VMHardDiskDrive @param
    }
    if ($childPath -match 'temp.vhdx') {
      $path = Join-Path -Path $Path.Replace("virtualMachines", "VirtualHardDisks") -ChildPath $VMName\'temp.vhdx'
      $param = @{
        Path      = $path
        SizeBytes = 50GB
        Dynamic   = $true
        Confirm   = $false
      }
      New-VHD @param
      $param = @{
        VMName             = $VMName
        Path               = $path
        ControllerType     = 'iscsi'
        ControllerNumber   = 0
        ControllerLocation = 6
        Confirm            = $false
      }
      Add-VMHardDiskDrive @param
    }
    if ($childPath -match 'ConfigMgrInstall.vhdx') {
      $path = Join-Path -Path $Path.Replace("virtualMachines", "VirtualHardDisks") -ChildPath $VMName\'ConfigMgrInstall.vhdx'
      $param = @{
        Path      = $path
        SizeBytes = 150GB
        Dynamic   = $true
        Confirm   = $false
      }
      New-VHD @param
      $param = @{
        VMName             = $VMName
        Path               = $path
        ControllerType     = 'iscsi'
        ControllerNumber   = 0
        ControllerLocation = 7
        Confirm            = $false
      }
      Add-VMHardDiskDrive @param
    }

  }
  else {
    Write-Output "[System.DateTime]::Now - [INFO] - No ConfigMgr Setting added to VMName: $VMName"
    Write-Output "[System.DateTime]::Now - [INFO] - To add the ConfigMgr Settings, please run the following command: Set-VMConfigurationSettings -VMName $VMName -AddConfigMgrSetting"
  }
}
