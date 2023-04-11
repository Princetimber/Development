<#
.SYNOPSIS
This function creates a new virtual machine with the specified parameters.
.DESCRIPTION
  This function creates a new virtual machine with the specified parameters. it also sets the VM configuration settings based on Virtual machine use case. e.g. if the VM is a DC, it will set the VM to use the DC configuration settings.
.PARAMETER Name
  The name of the virtual machine to be created.
.PARAMETER Path
  The path on the host where the virtual machine will be created.
.PARAMETER switchName
  The name of the virtual switch to be used for the virtual machine.
.PARAMETER MemoryStartupSize
  The memory startup size for the virtual machine.
.PARAMETER newVHDSize
  The size of the new VHD to be created for the virtual machine.
.PARAMETER VMName
  The name of the virtual machine to be configured.
.PARAMETER media
  The media to be used for the virtual machine.
.PARAMETER mediaBinaryLocation
  The location of the media binary.
.PARAMETER mediaPath
  The path of the media binary.
.PARAMETER AddDCSetting
  The switch to set the VM configuration settings for adomain controller VM use case.
.PARAMETER AddConfigMgrSetting
  The switch to set the VM configuration settings for a ConfigMgr VM use case.
.NOTES
  Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
  Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
  New-VirtualMachine -Name "DC01" -Path "C:\VirtualMachines\DC01" -MemoryStartupSize "8GB" -newVHDSize "80GB"
  This command creates a new virtual machine with the name DC01, the path is C:\VirtualMachines\DC01, the memory startup size is 8GB and the new VHD size is 80GB.
.EXAMPLE
Set-VMConfigurationSettings -VMName "DC01" -media "ws2k22.iso" -mediaBinaryLocation "E:\Media" -AddDCSetting
This command sets the VM configuration settings for the DC01 VM. The media is set to ws2k22.iso, the media binary location is E:\Media and the AddDCSetting switch is set.
.EXAMPLE
Set-VMConfigurationSettings -VMName "DC01" -media "ws2k22.iso" -mediaBinaryLocation "E:\Media" -AddConfigMgrSetting
This command sets the VM configuration settings for the DC01 VM. The media is set to ws2k22.iso, the media binary location is E:\Media and the AddConfigMgrSetting switch is set.
#>
Function New-VirtualMachine {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][string]$Name,
    [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][string]$Path,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 2)][ValidateSet('datacenter', 'internal')][string]$switchName = 'datacenter',
    [Parameter(Mandatory = $true, Position = 3, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidateSet("4GB", "8GB", "16GB", "32GB")][string]$MemoryStartupSize = "4GB",
    [Parameter(Mandatory = $false, Position = 4, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidateSet("40GB", "80GB", "100GB", "120GB")][string]$newVHDSize = "40GB",
    [Parameter(Mandatory = $false, Position = 5, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][switch]$Create
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
  If ($Create.IsPresent) {
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
  else {
    Write-Host "Add -Create switch to create the VM"
  }
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
