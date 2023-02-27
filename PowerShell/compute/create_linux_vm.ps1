# Define VM name(s)
$n = @('gateway', 'apache')

# Define VM Memory in MB
$memoryStartupBytes = 8200MB

# Define the installation media Path
$media = 'ubuntu.iso'
$mediaPath = 'e:\media'
$installMediaPath = Join-Path -Path $mediaPath -ChildPath $media

# Define VM switch Name
$switchName = (Get-VMSwitch -Name datacenter).Name

foreach ($i in $n) {
  # Define VM Path
  $path = Join-Path -Path e:\hyper-V\VirtualMachines -ChildPath $i
  $newVHDPath = Join-Path -Path e:\hyper-V\virtualHardDisks -ChildPath "$i\OSDisk.vhdx"
  $param = @{
    Name               = $i
    Path               = $path
    MemoryStartUpBytes = $memoryStartupBytes
    NewVHDPath         = $newVHDPath
    NewVHDSizeBytes    = 40GB
    SwitchName         = $switchName
    Generation         = 2
    Confirm            = $false
  }
  New-VM @param
  Start-Sleep -Milliseconds 600
  $param = @{
    VMName             = $i
    Path               = $installMediaPath
    ControllerNumber   = 0
    ControllerLocation = 1
    Confirm            = $false
  }
  Add-VMDvdDrive @param
  $vmDvDDrive = Get-VMDvdDrive -VMName $i
  $param = @{
    VMName               = $i
    FirstBootDevice      = $vmDvDDrive
    EnableSecureBoot     = 'on'
    SecureBootTemplate   = 'MicrosoftUEFICertificateAuthority'
    PreferredNetworkBoot = 'IPv4'
    Confirm              = $false
  }
  Set-VMFirmware @param
  # Set VMNetwork Adapter properties
  $param = @{
    VMName            = $i
    DynamicMacAddress = $true
    DeviceNaming      = 'on'
    DhcpGuard         = 'on'
    RouterGuard       = 'on'
    VmmqEnabled       = $true
    VrssEnabled       = $true
    AllowTeaming      = 'on'
  }
  Set-VMNetworkAdapter @param
  Enable-VMConsoleSupport -VMName $i
  $param = @{
    VMName               = $i
    NewLocalKeyProtector = $true
    Confirm              = $false
  }
  Set-VMKeyProtector @param
  Enable-VMTPM -VMName $i -Confirm:$false
  $param = @{
    VMName                            = $i
    EncryptStateAndVMMigrationTraffic = $true
    VirtualizationBasedSecurityOptOut = $false
    Confirm                           = $false
  }
  Set-VMSecurity @param
}

foreach ($i in $n) {
  $param = @{
    VMName               = $i
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
    VMName                           = $i
    Count                            = 2
    Reserve                          = 50
    RelativeWeight                   = 100
    CompatibilityForMigrationEnabled = $true
    Confirm                          = $false
  }
  Set-VMProcessor @param
}