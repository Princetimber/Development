<#
.SYNOPSIS
  This function sets the configuration of an existing virtual machine.
.DESCRIPTION
  This function sets the configuration of an existing virtual machine, using the Set-VM cmdlet and the specified parameters. it takes the Cofigure, AddDCSettings and AddConfigMgrSettings parameter sets.
.NOTES
  Information or caveats about the function e.g. 'This function is not supported in Linux'
.PARAMETER Configure
  The parameter set for configuring the virtual machine.
.PARAMETER AddDCSettings
  The parameter set for adding domain controller settings to the virtual machine.
.PARAMETER AddConfigMgrSettings
  The parameter set for adding Configuration Manager settings to the virtual machine.
.PARAMETER Name
  The name of the virtual machine.
.PARAMETER MediaBinaryName
  The name of the media binary to use for the virtual machine.
.PARAMETER MediaBinaryLocation
  The location of the media binary to use for the virtual machine.
.PARAMETER MediaBinaryPath
  The path of the media binary to use for the virtual machine.  This is a calculated property.
.PARAMETER Force
  If specified, the function will not prompt for confirmation.
.LINK
  Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
  Set-VirtualMachine -Configure -Name 'VM01' -MediaBinaryName 'Windows.iso' -MediaBinaryLocation 'E:\Media'
  This example configures the virtual machine named VM01, using the Windows.iso media binary.
.EXAMPLE
Set-VirtualMachine -AddDCSettings -Name 'VM01' -MediaBinaryName 'Windows.iso' -MediaBinaryLocation 'E:\Media'
  This example configures the virtual machine named VM01, using the Windows.iso media binary, and adds domain controller settings.
.EXAMPLE
Set-VirtualMachine -AddConfigMgrSettings -Name 'VM01' -MediaBinaryName 'Windows.iso' -MediaBinaryLocation 'E:\Media'
  This example configures the virtual machine named VM01, using the Windows.iso media binary, and adds Configuration Manager settings.
#>
Function Set-VirtualMachine {
  [CmdletBinding(DefaultParameterSetName = 'Configure', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
  Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Configure')][switch]$Configure,
    [Parameter(Mandatory = $true, ParameterSetName = 'AddDCSettings')][switch]$AddDCSettings,
    [Parameter(Mandatory = $true, ParameterSetName = 'AddConfigMgrSettings')][switch]$AddConfigMgrSettings,
    [Parameter(Mandatory = $true, Position = 0)][ValidateNotNullOrEmpty()][ValidateScript({
        If (-not (Get-VM -Name $_ -ErrorAction SilentlyContinue)) {
          Throw "Virtual machine '$($_)' does not exist."
        }
        Else {
          $true
        }
      })][string]$Name,
    [Parameter(Mandatory = $false, Position = 1)][ValidateSet('Ubuntu.iso', 'Windows.iso')][string]$MediaBinaryName,
    [Parameter(Mandatory = $false, Position = 2)][ValidateNotNullOrEmpty()][string]$MediaBinaryLocation = 'E:\Media',
    [Parameter(Mandatory = $false, Position = 3)][string]$MediaBinaryPath = (Join-Path $MediaBinaryLocation $MediaBinaryName),
    [Parameter(Mandatory = $false, HelpMessage = "If specified, the function will not prompt for confirmation.")][switch]$Force
  )
  #validate null or empty parameters for name and media binary path
  if ([string]::IsNullOrEmpty($Name)) {
    throw "The parameter 'Name' cannot be null or empty."
  }
  if ([string]::IsNullOrEmpty($MediaBinaryLocation)) {
    throw "The parameter 'MediaBinaryPath' cannot be null or empty."
  }
  $VM = Get-VM -Name $Name -ErrorAction SilentlyContinue
  switch ($PSCmdlet.ParameterSetName) {
    'Configure' {
      if ($PSCmdlet.ShouldProcess($Name, 'Configure Virtual Machine')) {
        if ($VM) {
          $vmParam = @{
            VMName             = $Name
            Path               = $MediaBinaryPath
            ControllerNumber   = 0
            ControllerLocation = 1
            Confirm            = $false
          }
          Add-VMDvdDrive @vmParam
          $VMDvDDrive = Get-VMDvdDrive -VMName $Name
          if ($MediaBinaryName.Equals('Ubuntu.iso') -or $MediaBinaryName.Equals('Kali.iso')) {
            $vmDvDparam = @{
              VMName               = $Name
              FirstBootDevice      = $VMDvDDrive
              EnableSecureBoot     = 'On'
              SecureBootTemplate   = 'MicrosoftUEFICertificateAuthority'
              PreferredNetworkBoot = 'IPv4'
              Confirm              = $false
            }
            Set-VMFirmware @vmDvDparam
          }
          elseIf ($MediaBinaryName.Equals('W*.iso')) {
            $vmDvDparam = @{
              VMName               = $Name
              FirstBootDevice      = $VMDvDDrive
              EnableSecureBoot     = 'On'
              SecureBootTemplate   = 'MicrosoftWindows'
              PreferredNetworkBoot = 'IPv4'
              Confirm              = $false
            }
            Set-VMFirmware @vmDvDparam
          }
          $param = @{
            VMName               = $Name
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
            VMName                           = $Name
            Count                            = 2
            Reserve                          = 50
            RelativeWeight                   = 100
            CompatibilityForMigrationEnabled = $true
            Confirm                          = $false
          }
          Set-VMProcessor @param
          $param = @{
            VMName            = $Name
            DynamicMacAddress = $true
            DeviceNaming      = 'on'
            DhcpGuard         = 'on'
            RouterGuard       = 'on'
            VmmqEnabled       = $true
            VrssEnabled       = $true
            AllowTeaming      = 'on'
          }
          Set-VMNetworkAdapter @param
          Enable-VMConsoleSupport -VMName $Name
          $param = @{
            VMName               = $Name
            NewLocalKeyProtector = $true
            Confirm              = $false
          }
          Set-VMKeyProtector @param
          Enable-VMTPM -VMName $Name
          $param = @{
            VMName                            = $Name
            EncryptStateAndVMMigrationTraffic = $true
            VirtualizationBasedSecurityOptOut = $false
            Confirm                           = $false
          }
          Set-VMSecurity @param
        }
      }
      Elseif ($PSCmdlet.ShouldContinue("The Virtual Machine '$Name' is not configured, do you want to configure it?", "Adding DC Server settings")) {
        if ($VM) {
          $vmParam = @{
            VMName             = $Name
            Path               = $MediaBinaryPath
            ControllerNumber   = 0
            ControllerLocation = 1
            Confirm            = $false
          }
          Add-VMDvdDrive @vmParam
          $VMDvDDrive = Get-VMDvdDrive -VMName $Name
          if ($MediaBinaryName.Equals('Ubuntu.iso') -or $MediaBinaryName.Equals('Kali.iso')) {
            $vmDvDparam = @{
              VMName               = $Name
              FirstBootDevice      = $VMDvDDrive
              EnableSecureBoot     = 'On'
              SecureBootTemplate   = 'MicrosoftUEFICertificateAuthority'
              PreferredNetworkBoot = 'IPv4'
              Confirm              = $false
            }
            Set-VMFirmware @vmDvDparam
          }
          elseIf ($MediaBinaryName.Equals('W*.iso')) {
            $vmDvDparam = @{
              VMName               = $Name
              FirstBootDevice      = $VMDvDDrive
              EnableSecureBoot     = 'On'
              SecureBootTemplate   = 'MicrosoftWindows'
              PreferredNetworkBoot = 'IPv4'
              Confirm              = $false
            }
            Set-VMFirmware @vmDvDparam
          }
          $param = @{
            VMName               = $Name
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
            VMName                           = $Name
            Count                            = 2
            Reserve                          = 50
            RelativeWeight                   = 100
            CompatibilityForMigrationEnabled = $true
            Confirm                          = $false
          }
          Set-VMProcessor @param
          $param = @{
            VMName            = $Name
            DynamicMacAddress = $true
            DeviceNaming      = 'on'
            DhcpGuard         = 'on'
            RouterGuard       = 'on'
            VmmqEnabled       = $true
            VrssEnabled       = $true
            AllowTeaming      = 'on'
          }
          Set-VMNetworkAdapter @param
          Enable-VMConsoleSupport -VMName $Name
          $param = @{
            VMName               = $Name
            NewLocalKeyProtector = $true
            Confirm              = $false
          }
          Set-VMKeyProtector @param
          Enable-VMTPM -VMName $Name
          $param = @{
            VMName                            = $Name
            EncryptStateAndVMMigrationTraffic = $true
            VirtualizationBasedSecurityOptOut = $false
            Confirm                           = $false
          }
          Set-VMSecurity @param
        }
      }
      else {
        Write-Warning "The Virtual Machine '$Name' is not configured, please configure it manually."
      }
    }
  }
  switch ($PSCmdlet.ParameterSetName) {
    'AddDCSettings' {
      if ($PSCmdlet.ShouldProcess($Name, "Adding Domain Controller Server Settings.")) {
        if ($VM) {
          $vmParam = @{
            VMName             = $Name
            Path               = $MediaBinaryPath
            ControllerNumber   = 0
            ControllerLocation = 1
            Confirm            = $false
          }
          Add-VMDvdDrive @vmParam
          $VMDvDDrive = Get-VMDvdDrive -VMName $Name
          if ($MediaBinaryName.Equals('Ubuntu.iso') -or $MediaBinaryName.Equals('Kali.iso')) {
            $vmDvDparam = @{
              VMName               = $Name
              FirstBootDevice      = $VMDvDDrive
              EnableSecureBoot     = 'On'
              SecureBootTemplate   = 'MicrosoftUEFICertificateAuthority'
              PreferredNetworkBoot = 'IPv4'
              Confirm              = $false
            }
            Set-VMFirmware @vmDvDparam
          }
          elseIf ($MediaBinaryName.Equals('W*.iso')) {
            $vmDvDparam = @{
              VMName               = $Name
              FirstBootDevice      = $VMDvDDrive
              EnableSecureBoot     = 'On'
              SecureBootTemplate   = 'MicrosoftWindows'
              PreferredNetworkBoot = 'IPv4'
              Confirm              = $false
            }
            Set-VMFirmware @vmDvDparam
          }
          $param = @{
            VMName               = $Name
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
            VMName                           = $Name
            Count                            = 2
            Reserve                          = 50
            RelativeWeight                   = 100
            CompatibilityForMigrationEnabled = $true
            Confirm                          = $false
          }
          Set-VMProcessor @param
          $param = @{
            VMName            = $Name
            DynamicMacAddress = $true
            DeviceNaming      = 'on'
            DhcpGuard         = 'on'
            RouterGuard       = 'on'
            VmmqEnabled       = $true
            VrssEnabled       = $true
            AllowTeaming      = 'on'
          }
          Set-VMNetworkAdapter @param
          Enable-VMConsoleSupport -VMName $Name
          $param = @{
            VMName               = $Name
            NewLocalKeyProtector = $true
            Confirm              = $false
          }
          Set-VMKeyProtector @param
          Enable-VMTPM -VMName $Name
          $param = @{
            VMName                            = $Name
            EncryptStateAndVMMigrationTraffic = $true
            VirtualizationBasedSecurityOptOut = $false
            Confirm                           = $false
          }
          Set-VMSecurity @param
          $childPath = @('log.vhdx', 'sysvol.vhdx', 'ntds.vhdx')
          $VMPath = Join-Path -Path E:\Hyper-V -ChildPath $Name
          $VHDPath = Join-Path -Path (Split-Path -Path $VMPath) -ChildPath 'virtualHardDisks'
          $ParentPath = Join-Path -Path $VHDPath -ChildPath $Name
          foreach ($child in $childPath) {
            if ($child.Equals('log.vhdx')) {
              $Path = Join-Path -Path $ParentPath -ChildPath $child
              $param = @{
                Path      = $Path
                SizeBytes = 20GB
                Dynamic   = $true
                Confirm   = $false
              }
              New-VHD @param
              $vhdParam = @{
                VMName             = $Name
                Path               = $Path
                ControllerNumber   = 0
                ControllerLocation = 2
                ControllerType     = 'SCSI'
                Confirm            = $false
              }
              Add-VMHardDiskDrive @vhdParam
            }
            ElseIf ($Child.Equals('sysvol.vhdx')) {
              $Path = Join-Path -Path $ParentPath -ChildPath $child
              $param = @{
                Path      = $Path
                SizeBytes = 20GB
                Dynamic   = $true
                Confirm   = $false
              }
              New-VHD @param
              $vhdParam = @{
                VMName             = $Name
                Path               = $Path
                ControllerNumber   = 0
                ControllerLocation = 3
                ControllerType     = 'SCSI'
                Confirm            = $false
              }
              Add-VMHardDiskDrive @vhdParam
            }
            ElseIf ($Child.Equals('ntds.vhdx')) {
              $Path = Join-Path -Path $ParentPath -ChildPath $child
              $param = @{
                Path      = $Path
                SizeBytes = 20GB
                Dynamic   = $true
                Confirm   = $false
              }
              New-VHD @param
              $vhdParam = @{
                VMName             = $Name
                Path               = $Path
                ControllerNumber   = 0
                ControllerLocation = 4
                ControllerType     = 'SCSI'
                Confirm            = $false
              }
              Add-VMHardDiskDrive @vhdParam
            }
          }
        }
        else {
          Write-Warning "The Virtual Machine '$Name' is not configured, please configure it manually."
        }
      }
      ElseIf ($PSCmdlet.ShouldContinue("The virtual machine $Name is not configured, do you want to configure?", "Continue?")) {
        if ($VM) {
          $vmParam = @{
            VMName             = $Name
            Path               = $MediaBinaryPath
            ControllerNumber   = 0
            ControllerLocation = 1
            Confirm            = $false
          }
          Add-VMDvdDrive @vmParam
          $VMDvDDrive = Get-VMDvdDrive -VMName $Name
          if ($MediaBinaryName.Equals('Ubuntu.iso') -or $MediaBinaryName.Equals('Kali.iso')) {
            $vmDvDparam = @{
              VMName               = $Name
              FirstBootDevice      = $VMDvDDrive
              EnableSecureBoot     = 'On'
              SecureBootTemplate   = 'MicrosoftUEFICertificateAuthority'
              PreferredNetworkBoot = 'IPv4'
              Confirm              = $false
            }
            Set-VMFirmware @vmDvDparam
          }
          elseIf ($MediaBinaryName.Equals('W*.iso')) {
            $vmDvDparam = @{
              VMName               = $Name
              FirstBootDevice      = $VMDvDDrive
              EnableSecureBoot     = 'On'
              SecureBootTemplate   = 'MicrosoftWindows'
              PreferredNetworkBoot = 'IPv4'
              Confirm              = $false
            }
            Set-VMFirmware @vmDvDparam
          }
          $param = @{
            VMName               = $Name
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
            VMName                           = $Name
            Count                            = 2
            Reserve                          = 50
            RelativeWeight                   = 100
            CompatibilityForMigrationEnabled = $true
            Confirm                          = $false
          }
          Set-VMProcessor @param
          $param = @{
            VMName            = $Name
            DynamicMacAddress = $true
            DeviceNaming      = 'on'
            DhcpGuard         = 'on'
            RouterGuard       = 'on'
            VmmqEnabled       = $true
            VrssEnabled       = $true
            AllowTeaming      = 'on'
          }
          Set-VMNetworkAdapter @param
          Enable-VMConsoleSupport -VMName $Name
          $param = @{
            VMName               = $Name
            NewLocalKeyProtector = $true
            Confirm              = $false
          }
          Set-VMKeyProtector @param
          Enable-VMTPM -VMName $Name
          $param = @{
            VMName                            = $Name
            EncryptStateAndVMMigrationTraffic = $true
            VirtualizationBasedSecurityOptOut = $false
            Confirm                           = $false
          }
          Set-VMSecurity @param
          $childPath = @('log.vhdx', 'sysvol.vhdx', 'ntds.vhdx')
          $VMPath = Join-Path -Path E:\Hyper-V -ChildPath $Name
          $VHDPath = Join-Path -Path (Split-Path -Path $VMPath) -ChildPath 'virtualHardDisks'
          $ParentPath = Join-Path -Path $VHDPath -ChildPath $Name
          foreach ($child in $childPath) {
            if ($child.Equals('log.vhdx')) {
              $Path = Join-Path -Path $ParentPath -ChildPath $child
              $param = @{
                Path      = $Path
                SizeBytes = 20GB
                Dynamic   = $true
                Confirm   = $false
              }
              New-VHD @param
              $vhdParam = @{
                VMName             = $Name
                Path               = $Path
                ControllerNumber   = 0
                ControllerLocation = 2
                ControllerType     = 'SCSI'
                Confirm            = $false
              }
              Add-VMHardDiskDrive @vhdParam
            }
            ElseIf ($Child.Equals('sysvol.vhdx')) {
              $Path = Join-Path -Path $ParentPath -ChildPath $child
              $param = @{
                Path      = $Path
                SizeBytes = 20GB
                Dynamic   = $true
                Confirm   = $false
              }
              New-VHD @param
              $vhdParam = @{
                VMName             = $Name
                Path               = $Path
                ControllerNumber   = 0
                ControllerLocation = 3
                ControllerType     = 'SCSI'
                Confirm            = $false
              }
              Add-VMHardDiskDrive @vhdParam
            }
            ElseIf ($Child.Equals('ntds.vhdx')) {
              $Path = Join-Path -Path $ParentPath -ChildPath $child
              $param = @{
                Path      = $Path
                SizeBytes = 20GB
                Dynamic   = $true
                Confirm   = $false
              }
              New-VHD @param
              $vhdParam = @{
                VMName             = $Name
                Path               = $Path
                ControllerNumber   = 0
                ControllerLocation = 4
                ControllerType     = 'SCSI'
                Confirm            = $false
              }
              Add-VMHardDiskDrive @vhdParam
            }
          }
        }
        else {
          Write-Warning "The Virtual Machine '$Name' is not configured, please configure it manually."
        }
      }
    }
  }
  switch ($PSCmdlet.ParameterSetName) {
    'AddConfigMgrSettings' {
      If ($PSCmdlet.ShouldProcess($Name, "Adding ConfigMgr Infrastructure Sever Settings")) {
        If ($VM) {
          $vmParam = @{
            VMName             = $Name
            Path               = $MediaBinaryPath
            ControllerNumber   = 0
            ControllerLocation = 1
            Confirm            = $false
          }
          Add-VMDvdDrive @vmParam
          $VMDvDDrive = Get-VMDvdDrive -VMName $Name
          if ($MediaBinaryName.Equals('Ubuntu.iso') -or $MediaBinaryName.Equals('Kali.iso')) {
            $vmDvDparam = @{
              VMName               = $Name
              FirstBootDevice      = $VMDvDDrive
              EnableSecureBoot     = 'On'
              SecureBootTemplate   = 'MicrosoftUEFICertificateAuthority'
              PreferredNetworkBoot = 'IPv4'
              Confirm              = $false
            }
            Set-VMFirmware @vmDvDparam
          }
          elseIf ($MediaBinaryName.Equals('W*.iso')) {
            $vmDvDparam = @{
              VMName               = $Name
              FirstBootDevice      = $VMDvDDrive
              EnableSecureBoot     = 'On'
              SecureBootTemplate   = 'MicrosoftWindows'
              PreferredNetworkBoot = 'IPv4'
              Confirm              = $false
            }
            Set-VMFirmware @vmDvDparam
          }
          $param = @{
            VMName               = $Name
            StaticMemory         = $true
            MemoryStartUpBytes   = 32800MB
            AutomaticStartAction = 'start'
            AutomaticStartDelay  = '120'
            AutomaticStopAction  = 'Shutdown'
            LockOnDisconnect     = 'on'
          }
          Set-VM @param
          $param = @{
            VMName                           = $Name
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
          $param = @{
            VMName            = $Name
            DynamicMacAddress = $true
            DeviceNaming      = 'on'
            DhcpGuard         = 'on'
            RouterGuard       = 'on'
            VmmqEnabled       = $true
            VrssEnabled       = $true
            AllowTeaming      = 'on'
          }
          Set-VMNetworkAdapter @param
          Enable-VMConsoleSupport -VMName $Name
          $param = @{
            VMName               = $Name
            NewLocalKeyProtector = $true
            Confirm              = $false
          }
          Set-VMKeyProtector @param
          Enable-VMTPM -VMName $Name
          $param = @{
            VMName                            = $Name
            EncryptStateAndVMMigrationTraffic = $true
            VirtualizationBasedSecurityOptOut = $false
            Confirm                           = $false
          }
          Set-VMSecurity @param
          $childPath = @('logs.vhdx', 'mdf.vhdx', 'ldf.vhdx', 'contentLibrary.vhdx', 'temp.vhdx', 'ConfigMgrInstall.vhdx')
          $VMPath = Join-Path -Path E:\Hyper-V -ChildPath $Name
          $VHDPath = Join-Path -Path (Split-Path -Path $VMPath) -ChildPath 'virtualHardDisks'
          $ParentPath = Join-Path -Path $VHDPath -ChildPath $Name
          foreach ($child in $childPath) {
            if ($child.Equals('logs.vhdx')) {
              $path = Join-Path -Path $ParentPath -ChildPath $child
              $param = @{
                Path      = $path
                SizeBytes = 50GB
                Dynamic   = $false
                Confirm   = $false
              }
              New-VHD @param
              $param = @{
                VMName             = $Name
                Path               = $path
                ControllerType     = 'scsi'
                ControllerNumber   = 0
                ControllerLocation = 2
                Confirm            = $false
              }
              Add-VMHardDiskDrive @param
            }
            elseif ($child.equals('mdf.vhdx')) {
              $path = Join-Path -Path $ParentPath -ChildPath $child
              $param = @{
                Path      = $path
                SizeBytes = 75GB
                Dynamic   = $false
                Confirm   = $false
              }
              New-VHD @param
              $param = @{
                VMName             = $Name
                Path               = $path
                ControllerType     = 'scsi'
                ControllerNumber   = 0
                ControllerLocation = 3
                Confirm            = $false
              }
              Add-VMHardDiskDrive @param
            }
            elseif ($child.equals('ldf.vhdx')) {
              $path = Join-Path -Path $ParentPath -ChildPath $child
              $param = @{
                Path      = $path
                SizeBytes = 75GB
                Dynamic   = $false
                Confirm   = $false
              }
              New-VHD @param
              $param = @{
                VMName             = $Name
                Path               = $path
                ControllerType     = 'scsi'
                ControllerNumber   = 0
                ControllerLocation = 4
                Confirm            = $false
              }
              Add-VMHardDiskDrive @param
            }
            elseif ($child.equals('contentLibrary.vhdx')) {
              $path = Join-Path -Path $ParentPath -ChildPath $child
              $param = @{
                Path      = $path
                SizeBytes = 500GB
                Dynamic   = $true
                Confirm   = $false
              }
              New-VHD @param
              $param = @{
                VMName             = $Name
                Path               = $path
                ControllerType     = 'scsi'
                ControllerNumber   = 0
                ControllerLocation = 5
                Confirm            = $false
              }
              Add-VMHardDiskDrive @param
            }
            elseif ($child.equals('temp.vhdx')) {
              $path = Join-Path -Path $ParentPath -ChildPath $child
              $param = @{
                Path      = $path
                SizeBytes = 500GB
                Dynamic   = $true
                Confirm   = $false
              }
              New-VHD @param
              $param = @{
                VMName             = $Name
                Path               = $path
                ControllerType     = 'scsi'
                ControllerNumber   = 0
                ControllerLocation = 6
                Confirm            = $false
              }
              Add-VMHardDiskDrive @param
            }
            elseif ($child.Equals('ConfigMgrInstall.vhdx')) {
              $path = Join-Path -Path $ParentPath -ChildPath $child
              $param = @{
                Path      = $path
                SizeBytes = 150GB
                Dynamic   = $false
                Confirm   = $false
              }
              New-VHD @param
              $param = @{
                VMName             = $Name
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
      elseIf ($PSCmdlet.ShouldContinue("The Virtual Machine '$Name', is not Configured, Do you want to continue?", "Continue")) {
        If ($VM) {
          $vmParam = @{
            VMName             = $Name
            Path               = $MediaBinaryPath
            ControllerNumber   = 0
            ControllerLocation = 1
            Confirm            = $false
          }
          Add-VMDvdDrive @vmParam
          $VMDvDDrive = Get-VMDvdDrive -VMName $Name
          if ($MediaBinaryName.Equals('Ubuntu.iso') -or $MediaBinaryName.Equals('Kali.iso')) {
            $vmDvDparam = @{
              VMName               = $Name
              FirstBootDevice      = $VMDvDDrive
              EnableSecureBoot     = 'On'
              SecureBootTemplate   = 'MicrosoftUEFICertificateAuthority'
              PreferredNetworkBoot = 'IPv4'
              Confirm              = $false
            }
            Set-VMFirmware @vmDvDparam
          }
          elseIf ($MediaBinaryName.Equals('W*.iso')) {
            $vmDvDparam = @{
              VMName               = $Name
              FirstBootDevice      = $VMDvDDrive
              EnableSecureBoot     = 'On'
              SecureBootTemplate   = 'MicrosoftWindows'
              PreferredNetworkBoot = 'IPv4'
              Confirm              = $false
            }
            Set-VMFirmware @vmDvDparam
          }
          $param = @{
            VMName               = $Name
            StaticMemory         = $true
            MemoryStartUpBytes   = 32800MB
            AutomaticStartAction = 'start'
            AutomaticStartDelay  = '120'
            AutomaticStopAction  = 'Shutdown'
            LockOnDisconnect     = 'on'
          }
          Set-VM @param
          $param = @{
            VMName                           = $Name
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
          $param = @{
            VMName            = $Name
            DynamicMacAddress = $true
            DeviceNaming      = 'on'
            DhcpGuard         = 'on'
            RouterGuard       = 'on'
            VmmqEnabled       = $true
            VrssEnabled       = $true
            AllowTeaming      = 'on'
          }
          Set-VMNetworkAdapter @param
          Enable-VMConsoleSupport -VMName $Name
          $param = @{
            VMName               = $Name
            NewLocalKeyProtector = $true
            Confirm              = $false
          }
          Set-VMKeyProtector @param
          Enable-VMTPM -VMName $Name
          $param = @{
            VMName                            = $Name
            EncryptStateAndVMMigrationTraffic = $true
            VirtualizationBasedSecurityOptOut = $false
            Confirm                           = $false
          }
          Set-VMSecurity @param
          $childPath = @('logs.vhdx', 'mdf.vhdx', 'ldf.vhdx', 'contentLibrary.vhdx', 'temp.vhdx', 'ConfigMgrInstall.vhdx')
          $VMPath = Join-Path -Path E:\Hyper-V -ChildPath $Name
          $VHDPath = Join-Path -Path (Split-Path -Path $VMPath) -ChildPath 'virtualHardDisks'
          $ParentPath = Join-Path -Path $VHDPath -ChildPath $Name
          foreach ($child in $childPath) {
            if ($child.Equals('logs.vhdx')) {
              $path = Join-Path -Path $ParentPath -ChildPath $child
              $param = @{
                Path      = $path
                SizeBytes = 50GB
                Dynamic   = $false
                Confirm   = $false
              }
              New-VHD @param
              $param = @{
                VMName             = $Name
                Path               = $path
                ControllerType     = 'scsi'
                ControllerNumber   = 0
                ControllerLocation = 2
                Confirm            = $false
              }
              Add-VMHardDiskDrive @param
            }
            elseif ($child.Equals('mdf.vhdx')) {
              $path = Join-Path -Path $ParentPath -ChildPath $child
              $param = @{
                Path      = $path
                SizeBytes = 75GB
                Dynamic   = $false
                Confirm   = $false
              }
              New-VHD @param
              $param = @{
                VMName             = $Name
                Path               = $path
                ControllerType     = 'scsi'
                ControllerNumber   = 0
                ControllerLocation = 3
                Confirm            = $false
              }
              Add-VMHardDiskDrive @param
            }
            elseif ($child.Equals('ldf.vhdx')) {
              $path = Join-Path -Path $ParentPath -ChildPath $child
              $param = @{
                Path      = $path
                SizeBytes = 75GB
                Dynamic   = $false
                Confirm   = $false
              }
              New-VHD @param
              $param = @{
                VMName             = $Name
                Path               = $path
                ControllerType     = 'scsi'
                ControllerNumber   = 0
                ControllerLocation = 4
                Confirm            = $false
              }
              Add-VMHardDiskDrive @param
            }
            elseif ($child.Equals('contentLibrary.vhdx')) {
              $path = Join-Path -Path $ParentPath -ChildPath $child
              $param = @{
                Path      = $path
                SizeBytes = 500GB
                Dynamic   = $true
                Confirm   = $false
              }
              New-VHD @param
              $param = @{
                VMName             = $Name
                Path               = $path
                ControllerType     = 'scsi'
                ControllerNumber   = 0
                ControllerLocation = 5
                Confirm            = $false
              }
              Add-VMHardDiskDrive @param
            }
            elseif ($child.Equals('temp.vhdx')) {
              $path = Join-Path -Path $ParentPath -ChildPath $child
              $param = @{
                Path      = $path
                SizeBytes = 500GB
                Dynamic   = $true
                Confirm   = $false
              }
              New-VHD @param
              $param = @{
                VMName             = $Name
                Path               = $path
                ControllerType     = 'scsi'
                ControllerNumber   = 0
                ControllerLocation = 6
                Confirm            = $false
              }
              Add-VMHardDiskDrive @param
            }
            elseif ($child.Equals('ConfigMgrInstall.vhdx')) {
              $path = Join-Path -Path $ParentPath -ChildPath $child
              $param = @{
                Path      = $path
                SizeBytes = 150GB
                Dynamic   = $false
                Confirm   = $false
              }
              New-VHD @param
              $param = @{
                VMName             = $Name
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
      else {
        Write-Warning "The Virtual Machine' $Name', is not Configured, please configure it manually."
      }
    }
  }
}