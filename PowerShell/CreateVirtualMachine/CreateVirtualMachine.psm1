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
.PARAMETER Configure
  The switch to set the VM configuration settings.
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
  Information or caveats about the function e.g. 'This function is not supported in Linux'.
The following paramters are not hardcoded and can be modified to meet org needs. These includes the -Path, -switchName, -MemoryStartUpBytes, -newVHDSize, -media, -mediaBinaryLocation, -mediaPath
.LINK
  Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
  New-VirtualMachine -Name "web1" -Path "E:\hyper-v\virtualMachines\web1" -switchName "datacenter" -MemoryStartUpBytes 4GB -newVHDSize 40GB -Create
  This command creates a new virtual machine with the specified parameters.
  This command will only execute the New-VM cmdlet if the -Create switch is specified.
.EXAMPLE
  set-VMConfigurationSettings -VMName "web1" -media ubuntu.iso -Configure
  This command sets the VM configuration settings for the specified VM.
  This command will only execute the Set-VM cmdlet if the -Configure switch is specified.
  This is targetting a generic VM use case.
.EXAMPLE
  set-VMConfigurationSettings -VMName "web1" -media ubuntu.iso -Configure -AddDCSetting
  This command sets the VM configuration settings for the specified VM.
  This command will only execute the Set-VM cmdlet if the -Configure and -AddDCSetting switches are specified.
  This is targetting a DC VM use case.
.EXAMPLE
  set-VMConfigurationSettings -VMName "web1" -media ubuntu.iso -Configure -AddConfigMgrSetting
  This command sets the VM configuration settings for the specified VM.
  This command will only execute the Set-VM cmdlet if the -Configure and -AddConfigMgrSetting switches are specified.
  This is targetting a ConfigMgr VM use case.
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
    [Parameter(Mandatory = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$VMName,
    [Parameter(Mandatory = $false, Position = 1)][ValidateSet('ubuntu.iso', 'kali.iso', 'ws2k22.iso', 'w1121h2.iso')][string]$media = 'ubuntu.iso',
    [Parameter(Mandatory = $false, Position = 2)][ValidateNotNullOrEmpty()][string]$mediaBinaryLocation = 'E:\Media',
    [Parameter(Mandatory = $false, Position = 3)][string]$mediaPath = (Join-Path -Path $mediaBinaryLocation -ChildPath $media),
    [Parameter(Mandatory = $false, Position = 4, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][switch]$Configure,
    [Parameter(Mandatory = $false, Position = 5)][switch]$AddDCSetting,
    [Parameter(Mandatory = $false, Position = 6)][switch]$AddConfigMgrSetting
  )
  if ([string]::IsNullOrEmpty($VMName)) {
    Write-Error "VMName cannot be null or empty"
  }
  if ([string]::IsNullOrEmpty($mediaBinaryLocation)) {
    Write-Error "mediaBinaryLocation cannot be null or empty"
  }
  if ($Configure.IsPresent) {
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
  else {
    Write-Host "Add -AddAdditionalConfigurations switch to add additional configurations"
  }
  if ($AddDCSetting.IsPresent) {
    $param = @{
      VMName               = $VMName
      DynamicMemory        = $true
      MemoryMaximumBytes   = 4100MB
      MemoryMinimumBytes   = 2050MB
      MemoryStartUpBytes   = 4100MB
      AutomaticStartAction = 'start'
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
    }
  }
  elseif ($AddConfigMgrSetting.IsPresent) {
    $param = @{
      VMName               = $VMName
      StaticMemory         = $true
      MemoryStartUpBytes   = 32800MB
      AutomaticStartAction = 'start'
      AutomaticStartDelay  = '120'
      AutomaticStopAction  = 'Shutdown'
      LockOnDisconnect     = 'on'
    }
    Set-VM @param
    $param = @{
      VMName                           = $VMName
      Count                            = 4
      Reserve                          = 0
      MaximumCountPerNumaSocket        = 2
      MaximumCountPerNumaNode          = 2
      HwThreadCountPerCore             = 1
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
    }
  }
}
