<#
.SYNOPSIS
The function New-VirtualMachine is used to created a VM by setting required parameters.
The function Set-VirtualMachine is used to configure the VM by setting required parameters.
The function Remove-VirtualMachine is used to remove the VM by setting required parameters.
The funtion Start-VirtualMachine is used to start the VM by setting required parameters.
The function Stop-VirtualMachine is used to stop the VM by setting required parameters, and optionally stop the virtual machine host.
.DESCRIPTION
  The function New-VirtualMachine is used to created a VM by setting required parameters.The function will execute the New-VM cmdlet, using the provided parameters.the -Create switch is required to execute the New-VM cmdlet.
  The function Set-VirtualMachine is used to configure the VM by setting required parameters.this function will execute the Set-VM cmdlet, using the provided parameters.The -Configure switch is required to execute the Set-VM cmdlet.
  The function Remove-VirtualMachine is used to remove the VM by setting required parameters. This function will execute the Remove-VM cmdlet, using the provided parameters.The -Remove switch is required to execute the Remove-VM cmdlet.
  The funtion Start-VirtualMachine is used to start the VM by setting required parameters. This function will execute the Start-VM cmdlet, using the provided parameters.The -Start switch is required to execute the Start-VM cmdlet.
  The function Stop-VirtualMachine is used to stop the VM by setting required parameters, and optionally stop the virtual machine host. This function will execute the Stop-VM cmdlet, using the provided parameters.The -Stop switch is required to execute the Stop-VM cmdlet, which will stop the virtual machine.The -All switch is required to execute the Stop-VM cmdlet, whill stop all running virtual machines on the host.
  The -IncludingHost switch is required to execute the Stop-VM cmdlet, which will stop all running virtual machines on the host and then execute the Stop-Computer cmdlet to stop the host.
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
Please review and modify the following parameters to meet your org needs.
-Name
-Path
-switchName
-MemoryStartUpBytes
-newVHDSize
-VMName
-media
-mediaBinaryLocation
-mediaPath
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
.EXAMPLE
  Remove-VirtualMachine -Name "web1" -Remove
  This command removes the specified VM.
  This command will only execute the Remove-VM cmdlet if the -Remove switch is specified.
.EXAMPLE
  Start-VirtualMachine -Name "web1" -Start
  This command starts the specified VM.
  This command will only execute the Start-VM cmdlet if the -Start switch is specified.
.EXAMPLE
  Stop-VirtualMachine -Name "web1" -Stop
  This command stops the specified VM.
  This command will only execute the Stop-VM cmdlet if the -Stop switch is specified.
.EXAMPLE
  Stop-VirtualMachine -All
  This command stops all running VMs on the host.
  This command will only execute the Stop-VM cmdlet if the -All switches are specified, which stops all running virtual machines.
.EXAMPLE
  Stop-VirtualMachine -IncludingHost
  This command stops all running VMs on the host and then stops the host.
  This command will only execute the Stop-VM and Stop-Computer cmdlets if -IncludingHost switch are specified.
  This command will stop all running virtual machines on the host and then execute the Stop-Computer cmdlet to stop the host.
#>
Function New-VirtualMachine {
  [CmdletBinding(DefaultParameterSetName = 'Create', ConfirmImpact = 'Medium', SupportsShouldProcess = $true)]
  Param (
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidateScript({
        if (-not(Get-VM -Name $_ -ErrorAction SilentlyContinue)) {
          $true
        } else {
          throw "VM with name '$($_)' already exists."
        }
      })][ValidateNotNullOrEmpty()][string]$Name,
    [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidateScript({
        if (-not(Test-Path -Path $_ -PathType Container)) {
          throw "Path '$($_)' does not exist."
        } else {
          $true
        }
      })][ValidateNotNullOrEmpty()][string]$Path,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 2)][ValidateSet('datacenter', 'internal')][string]$switchName = 'datacenter',
    [Parameter(Mandatory = $true, Position = 3, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidateSet("4GB", "8GB", "16GB", "32GB")][string]$MemoryStartupSize = "4GB",
    [Parameter(Mandatory = $false, Position = 4, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidateSet("40GB", "80GB", "100GB", "120GB")][string]$newVHDSize = "40GB",
    [Parameter(ParameterSetName = 'Create', Mandatory = $false, Position = 5, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][switch]$Create,
    [Parameter(Mandatory = $false, HelpMessage = "If specified, the function will not prompt for confirmation.")][switch]$Force

  )
  if ([string]::IsNullOrEmpty($Name)) {
    Write-Error "Name cannot be null or empty"
  }
  if ([string]::IsNullOrEmpty($Path)) {
    Write-Error "Path cannot be null or empty"
  }
  $MemoryStartupSizeInGB = switch ($MemoryStartupSize) {
    "4GB" { 4GB }
    "8GB" { 8GB }
    "16GB" { 16GB }
    "32GB" { 32GB }
  }
  $VHDSizeInGB = switch ($newVHDSize) {
    "40GB" { 40GB }
    "80GB" { 80GB }
    "100GB" { 100GB }
    "120GB" { 120GB }
  }
  $VMPath = Join-Path -Path $Path -ChildPath $Name
  $VHDPath = Join-Path -Path (Split-Path -Path $Path) -ChildPath "VirtualHardDisks"
  $NewVHDPath = Join-Path -Path $VHDPath -ChildPath ($Name + '\' + "$Name.vhdx")
  switch ($PSCmdlet.ParameterSetName) {
    'Create' {
      if ($Force.IsPresent -or $PSCmdlet.ShouldProcess($Name, "Create VM")) {
        $param = @{
          Name               = $Name
          Path               = $VMPath
          memorystartupbytes = $MemoryStartupSizeInGB
          newvhdPath         = $NewVHDPath
          newvhdSizeBytes    = $VHDSizeInGB
          switchName         = $switchName
          generation         = 2
        }
        New-VM @param
      } elseIf ($Force.IsPresent -and $PSCmdlet.ShouldContinue("Do you want to create the VM?", "Creating VM")) {
        $param = @{
          Name               = $Name
          Path               = $VMPath
          memorystartupbytes = $MemoryStartupSizeInGB
          newvhdPath         = $NewVHDPath
          newvhdSizeBytes    = $VHDSizeInGB
          switchName         = $switchName
          generation         = 2
        }
        New-VM @param
      } else {
        Write-Warning "VM creation aborted."
      }
    }
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
    } elseif ($media -notlike 'kali.iso' -or $media -notlike 'ubuntu.iso') {
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
  } else {
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
      } elseif ($child -match 'sysvol.vhdx') {
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
      } elseif ($child -match 'ntds.vhdx') {
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
  } elseif ($AddConfigMgrSetting.IsPresent) {
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
      } elseif ($child -match 'mdf.vhdx') {
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
      } elseif ($child -match 'ldf.vhdx') {
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
      } elseif ($child -match 'contentlibrary.vhdx') {
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
      } elseif ($child -match 'temp.vhdx') {
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
      } elseif ($child -match 'ConfigMgrInstall.vhdx') {
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
function Remove-VirtualMachine {
  [CmdletBinding(DefaultParameterSetName = 'Remove', PositionalBinding = $true, ConfirmImpact = 'High', SupportsShouldProcess = $true)]
  param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "VM name to remove.")][ValidateNotNullOrEmpty()][ValidateScript({
        If (!(Get-VM -Name $_ -ErrorAction SilentlyContinue)) {
          throw "The virtual machine with the name $Name does not exist."
        }
        $true
      })][string]$Name,
    [Parameter(Mandatory = $true, Position = 1, HelpMessage = "Path to the virtual machine.")][ValidateNotNullOrEmpty()][ValidateScript({
        If (!(Test-Path -Path $_ -PathType Container -ErrorAction SilentlyContinue)) {
          throw "The path container $Path does not exist."
        }
        $true
      })][string]$Path,
    [Parameter(ParameterSetName = 'Remove', Mandatory = $true, Position = 2, HelpMessage = "Required to remove VM.")][switch]$Remove,
    [Parameter(Mandatory = $false, HelpMessage = "If specified, the function will not prompt for confirmation.")][switch]$Force
  )
  if ([string]::IsNullOrEmpty($Name)) {
    throw "The parameter Name is required, and cannot be null or empty."
  }
  if ([string]::IsNullOrEmpty($Path)) {
    throw "The parameter Path is required, and cannot be null or empty."
  }
  $VHDPath = Join-Path -Path (Split-Path -Path $Path) -ChildPath "VirtualHardDisks"
  $ExisitngVHDPath = Join-Path -Path $VHDPath -ChildPath $Name
  switch ($PSCmdlet.ParameterSetName) {
    'Remove' {
      if ($Force.IsPresent -or $PSCmdlet.ShouldProcess($Name, "Remove virtual machine")) {
        if ((Get-VM -Name $Name | Where-Object { $_.State -eq 'Running' })) {
          Stop-VM -Name $Name -Force -TurnOff
          Remove-VM -Name $Name -Force
          Remove-Item -Path $Path -Force -Recurse
          Remove-Item -Path $ExisitngVHDPath -Force -Recurse
        }
      } elseif ($Force.IsPresent -and $PSCmdlet.ShouldContinue("Do you want to remove the virtual machine $Name?", "Remove virtual machine")) {
        if ((Get-VM -Name $Name | Where-Object { $_.State -eq 'Off' })) {
          Remove-VM -Name $Name -Force
          Remove-Item -Path $Path -Force -Recurse
          Remove-Item -Path $ExisitngVHDPath -Force -Recurse
        }
      } else {
        Write-Warning "The virtual machine $Name was not removed."
      }
    }
  }
}
function Start-VirtualMachine {
  [CmdletBinding(DefaultParameterSetName = 'Start', ConfirmImpact = 'Medium', PositionalBinding = $true, SupportsShouldProcess = $true)]
  param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "VM name to start.")][ValidateNotNullOrEmpty()][ValidateScript({
        If (!(Get-VM -Name $_ -ErrorAction SilentlyContinue)) {
          throw "The virtual machine with the name $Name does not exist."
        }
        $true
      })][string]$Name,
    [Parameter(ParameterSetName = 'Start', Mandatory = $true, Position = 1, HelpMessage = "Required to start VM.")][switch]$Start,
    [Parameter(Mandatory = $false, HelpMessage = "If specified, the function will not prompt for confirmation.")][switch]$Force
  )
  if ([string]::IsNullOrEmpty($Name)) {
    throw "The virtual machine name is required."
  }
  switch ($PSCmdlet.ParameterSetName) {
    'Start' {
      if ($Force.IsPresent -or $PSCmdlet.ShouldProcess($Name, "Start virtual machine")) {
        Get-VM -Name $Name | Start-VM -Confirm:$false
      } elseif ($Force -and $PSCmdlet.ShouldContinue("Do you want to start the virtual machine $Name?", "Start virtual machine")) {
        Get-VM -Name $Name | Start-VM
      }
    }
  }
}
function Stop-VirtualMachine {
  [CmdletBinding(DefaultParameterSetName = 'All', ConfirmImpact = 'Medium', SupportsShouldProcess = $true)]
  Param(
    [Parameter(Mandatory = $false, Position = 3, HelpMessage = "Enter the name of the VM to be stopped.")][ValidateScript({
        If (Get-VM -Name $_ -ErrorAction SilentlyContinue) {
          $true
        } else {
          throw "The virtual machine with the name $Name does not exist."
        }
      })][string]$Name,
    [Parameter(ParameterSetName = 'All', Mandatory, Position = 0, HelpMessage = "Stops all running VMs.")][switch]$All,
    [Parameter(ParameterSetName = 'IncludingHost', Mandatory, Position = 1, HelpMessage = "Stops all running VMs and the VMHost.")][switch]$IncludingHost,
    [Parameter(ParameterSetName = 'VirtualMachine', Mandatory, Position = 2, HelpMessage = "Stops a single machine.")][switch]$VirtualMachine,
    [Parameter(Mandatory = $false, HelpMessage = "If specified, the function will not prompt for confirmation.")][switch]$Force
  )
  Set-StrictMode -Version 2.0
  $ErrorActionPreference = 'Stop'
  $VM = (Get-VM | Where-Object { $_.State -eq 'Running' }).Name -join ', '
  switch ($PSCmdlet.ParameterSetName) {
    'VirtualMachine' {
      if ($Force.IsPresent -and $PSCmdlet.ShouldContinue("Are you sure you want to stop the virtual machine $Name?", "Confirm Stop Virtual Machine")) {
        if ((Get-VM -Name $Name).State -eq 'Running') {
          Get-VM -Name $Name | Stop-VM -Force | Out-Null
        }
      } elseif ($Force.IsPresent -or $PSCmdlet.ShouldProcess($Name, "Stop Virtual Machine")) {
        if ((Get-VM -Name $Name).State -eq 'Running') {
          Get-VM -Name $Name | Stop-VM | Out-Null
        }
      } else {
        Write-Warning "Virtual Machine $Name is not stopped."
      }

    }
    'All' {
      if ($Force.IsPresent -and $PSCmdlet.ShouldContinue("Are you sure you want to stop all running virtual machines?", "Confirm Stop Virtual Machines")) {
        if ((Get-VM).State -eq 'Running') {
          Get-VM | Where-Object { $_.State -eq 'Running' } | Stop-VM -Force | Out-Null
        }
      } elseif ($Force.IsPresent -or $PSCmdlet.ShouldProcess($VM, "Stop Virtual Machines")) {
        if ((Get-VM).State -eq 'Running') {
          Get-VM | Where-Object { $_.State -eq 'Running' } | Stop-VM -Force | Out-Null
        }
      } else {
        Write-Warning "The virtual machine $VM is running."
      }
    }
    'IncludingHost' {
      if ($Force.IsPresent -or $PSCmdlet.ShouldProcess($VM, "Stop Virtual Machines and Host")) {
        if ((Get-VM).State -eq 'Running') {
          Get-VM | Where-Object { $_.State -eq 'Running' } | Stop-VM -Force | Out-Null
          Stop-Computer -Force
        }
        if ((Get-VM).State -ne 'Running') {
          Stop-Computer -Force
        }
      } elseIf ($Force.IsPresent -and $PSCmdlet.ShouldContinue("Are you sure you want to stop all running virtual machines and the host?", "Confirm Stop Virtual Machines and Host")) {
        if ((Get-VM).State -eq 'Running') {
          Get-VM | Where-Object { $_.State -eq 'Running' } | Stop-VM -Force | Out-Null
          Stop-Computer -Force
        }
        if ((Get-VM).State -ne 'Running') {
          Stop-Computer -Force
        }
      } else {
        Write-Warning "The virtual machine $VM is running and the VMHost $env:COMPUTERNAME is also running."
        return
      }
    }
  }
}
