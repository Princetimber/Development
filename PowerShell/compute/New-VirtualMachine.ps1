Function New-VirtualMachine {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$Name,
    [Parameter(Mandatory = $true, Position = 1)]
    [ValidateNotNullOrEmpty()]
    [string]$Path,
    [Parameter(Mandatory = $false, Position = 2)]
    [ValidateSet('datacenter', 'internal')]
    [string]$switchName = 'datacenter',
    [Parameter(Mandatory = $true, Position = 3)]
    [ValidateSet("4GB", "8GB", "16GB", "32GB")]
    [string]$MemoryStartupSize = "4GB",
    [Parameter(Mandatory = $false, Position = 4)]
    [ValidateSet("40GB", "80GB", "100GB", "120GB")]
    [string]$newVHDSize = "40GB"
  )
  if ([string]::IsNullOrEmpty($Name)) {
    Write-Error "Name cannot be null or empty"
  }
  if ([string]::IsNullOrEmpty($Path)) {
    Write-Error "Path cannot be null or empty"
  }
  $MemoryStartupBytes = switch ($MemoryStartupSize) {
    "4GB" { 4GB }
    "8GB" { 8GB }
    "16GB" { 16GB }
    "32GB" { 32GB }
  }
  $newVHDSizeBytes = switch ($newVHDSize) {
    "40GB" { 40GB }
    "80GB" { 80GB }
    "100GB" { 100GB }
    "120GB" { 120GB }
  }

  $newVHDPath = Join-Path -Path ($Path.Replace("virtualMachines", "VirtualHardDisks")) -ChildPath $Name\"osdisk.vhdx"
  $param = @{
    name               = $Name
    path               = $Path
    memorystartupbytes = $MemoryStartupBytes
    newvhdPath         = $newvhdpath
    newvhdSizeBytes    = $newVHDSizeBytes
    switchName         = $switchName
    generation         = 2
  }
  New-VM @param
}
function set-VMConfigurationSettings {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$VMName,
    [Parameter(Mandatory = $false, Position = 1)]
    [ValidateSet('ubuntu.iso', 'kali.iso', 'ws2k22.iso', 'w1121h2.iso')]
    [string]$media = 'ubuntu.iso',
    [Parameter(Mandatory = $false, Position = 2)]
    [ValidateNotNullOrEmpty()]
    [string]$mediaBinaryLocation = 'E:\Media',
    [Parameter(Mandatory = $false, Position = 3)]
    [string]$mediaPath = (Join-Path -Path $mediaBinaryLocation -ChildPath $media),
    [Parameter(Mandatory = $false, Position = 4)]
    [switch]$AddDCSetting,
    [Parameter(Mandatory = $false, Position = 5)]
    [switch]$AddConfigMgrSetting
  )
  if ([string]::IsNullOrEmpty($VMName)) {
    Write-Error "VMName cannot be null or empty"
  }
  if ([string]::IsNullOrEmpty($mediaBinaryLocation)) {
    Write-Error "mediaBinaryLocation cannot be null or empty"
  }
  $param = @{
    VMName             = $VMName
    Path               = $mediaPath
    ControllerNumber   = 0
    ControllerLocation = 1
    Confirm            = $false
  }
  Add-VMDvdDrive @param
  $VMDvDDrive = Get-VMDvdDrive -VMName $VMName
  If ($media -like 'Kali.iso' -or $media -like 'ubuntu.iso') {
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
  elseif ($media -notlike 'kali.iso' -or $media -notlike 'ubuntu.iso') {
    $param = @{
      VMName               = $VMName
      FirstBootDevice      = $VMDvDDrive
      EnableSecureBoot     = 'off'
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
    $childPath = @('log.vhdx', 'sysvol.vhdx', 'ntds.vhdx')
    foreach ($child in $childPath) {
      $parentPath = Join-Path -Path E:\Hyper-V\VirtualMachines\ -ChildPath $VMName
      if ($child -match 'log.vhdx') {
        $path = Join-Path -Path $parentPath.Replace('virtualMachines', 'virtualHardDisks') -ChildPath "$child"
        $param = @{
          Path      = $path
          SizeBytes = 20GB
          Dynamic   = $false
          Confirm   = $false
        }
        New-VHD @param
        $param = @{
          VMName             = $VMName
          Path               = $path
          ControllerType     = 'scsi'
          ControllerNumber   = 0
          ControllerLocation = 2
          Confirm            = $false
        }
        Add-VMHardDiskDrive @param
      }
      elseif ($child -match 'sysvol.vhdx') {
        $path = Join-Path -Path $parentPath.Replace('virtualMachines', 'virtualHardDisks') -ChildPath "$child"
        $param = @{
          Path      = $path
          SizeBytes = 20GB
          Dynamic   = $false
          Confirm   = $false
        }
        New-VHD @param
        $param = @{
          VMName             = $VMName
          Path               = $path
          ControllerType     = 'scsi'
          ControllerNumber   = 0
          ControllerLocation = 3
          Confirm            = $false
        }
        Add-VMHardDiskDrive @param
      }
      elseif ($child -match 'ntds.vhdx') {
        $path = Join-Path -Path $parentPath.Replace('virtualMachines', 'virtualHardDisks') -ChildPath "$child"
        $param = @{
          Path      = $path
          SizeBytes = 20GB
          Dynamic   = $false
          Confirm   = $false
        }
        New-VHD @param
        $param = @{
          VMName             = $VMName
          Path               = $path
          ControllerType     = 'scsi'
          ControllerNumber   = 0
          ControllerLocation = 4
          Confirm            = $false
        }
        Add-VMHardDiskDrive @param
      }
      else {
        Write-Output [system.DateTime]::Now.ToString("dd/MM/yyyy HH:MM")+"-[INFO] - No Domain Controller Settings added"
        Write-Output [system.DateTime]::Now.ToString("dd/MM/yyyy HH:MM")+" -[INFO] - To add the Domain Controller Settings, please run the following command: Set-VMConfigurationSettings -VMName $VMName -AddDCSetting"
      }
    }
  }
  if ($AddConfigMgrSetting.IsPresent) {
    $param = @{
      VMName                       = $VMName
      StaticMemory                 = $true
      MemoryStartUpBytes           = 32800MB
      AutomaticStartAction         = 'Start'
      AutomaticStopAction          = 'Shutdown'
      AutomaticStartDelay          = 90
      AutomaticCriticalErrorAction = 'Pause'
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
    $childPath = @('logs.vhdx', 'mdf.vhdx', 'ldf.vhdx', 'contentLibrary.vhdx', 'temp.vhdx', 'ConfigMgrInstall.vhdx')
    foreach ($child in $childPath) {
      $parentPath = Join-Path -Path E:\Hyper-V\VirtualMachines\ -ChildPath $VMName
      if ($child -match 'logs.vhdx') {
        $path = Join-Path -Path $parentPath.Replace('virtualMachines', 'virtualHardDisks') -ChildPath "$child"
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
          ControllerType     = 'scsi'
          ControllerNumber   = 0
          ControllerLocation = 2
          Confirm            = $false
        }
        Add-VMHardDiskDrive @param
      }
      elseif ($child -match 'mdf.vhdx') {
        $path = Join-Path -Path $parentPath.Replace('virtualMachines', 'virtualHardDisks') -ChildPath "$child"
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
          ControllerType     = 'scsi'
          ControllerNumber   = 0
          ControllerLocation = 3
          Confirm            = $false
        }
        Add-VMHardDiskDrive @param
      }
      elseif ($child -match 'ldf.vhdx') {
        $path = Join-Path -Path $parentPath.Replace('virtualMachines', 'virtualHardDisks') -ChildPath "$child"
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
          ControllerType     = 'scsi'
          ControllerNumber   = 0
          ControllerLocation = 4
          Confirm            = $false
        }
        Add-VMHardDiskDrive @param
      }
      elseif ($child -match 'contentlibrary.vhdx') {
        $path = Join-Path -Path $parentPath.Replace('virtualMachines', 'virtualHardDisks') -ChildPath "$child"
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
          ControllerType     = 'scsi'
          ControllerNumber   = 0
          ControllerLocation = 5
          Confirm            = $false
        }
        Add-VMHardDiskDrive @param
      }
      elseif ($child -match 'temp.vhdx') {
        $path = Join-Path -Path $parentPath.Replace('virtualMachines', 'virtualHardDisks') -ChildPath "$child"
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
          ControllerType     = 'scsi'
          ControllerNumber   = 0
          ControllerLocation = 6
          Confirm            = $false
        }
        Add-VMHardDiskDrive @param
      }
      elseif ($child -match 'ConfigMgrInstall.vhdx') {
        $path = Join-Path -Path $parentPath.Replace('virtualMachines', 'virtualHardDisks') -ChildPath "$child"
        $param = @{
          Path      = $path
          SizeBytes = 150GB
          Dynamic   = $false
          Confirm   = $false
        }
        New-VHD @param
        $param = @{
          VMName             = $VMName
          Path               = $path
          ControllerType     = 'scsi'
          ControllerNumber   = 0
          ControllerLocation = 7
          Confirm            = $false
        }
        Add-VMHardDiskDrive @param
      }
      else {
        Write-Output [System.DateTime]::Now.ToString("dd/MM/yyyy HH:MM")+ " - [INFO] - No ConfigMgr Setting added to VMName: $VMName"
        Write-Output  [System.DateTime]::Now.ToString("dd/MM/yyyy HH:MM")+" - [INFO] - To add the ConfigMgr Settings, please run the following command: Set-VMConfigurationSettings -VMName $VMName -AddConfigMgrSetting"
      }
    }
  }
}
