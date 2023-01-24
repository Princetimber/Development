$n = @('dc1', 'dc2')
$memoryStartupBytes = 8GB
$media = 'win2022.iso'
$mediaPath = 'e:\media'
$installMediaPath = Join-Path -Path $mediaPath -ChildPath $media
$switchName = (Get-VMSwitch -Name datacenter).Name
foreach ($i in $n) {
  $path = Join-Path -Path e:\hyper-V\VirtualMachines -ChildPath $i
  $newVHDPath = Join-Path -Path e:\hyper-V\virtualHardDisks -ChildPath "$i\OSDisk.vhdx"
  $param = @{
    Name               = $i
    Path               = $path
    MemoryStartUpBytes = $memoryStartupBytes
    NewVHDPath         = $newVHDPath
    NewVHDSizeBytes    = 60GB
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
    SecureTemplate       = 'MicrosoftWindows'
    PrefeeredNetworkBoot = 'IPv4'
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
  $newVHDPath = Join-Path -Path 'e:\hyper-v\VirtualHardDisks' -ChildPath "$i\logs.vhdx"
  $param = @{
    Path      = $newVHDPath
    SizeBytes = 25GB
    Dynamic   = $false
    Confirm   = $false
  }
  New-VHD @param
  $param = @{
    VMName             = $i
    Path               = $newVHDPath
    ControllerType     = 'scsi'
    ControllerNumber   = 0
    ControllerLocation = 2
    Confirm            = $false
  }
  Add-VMHardDiskDrive @param
}
foreach ($i in $n) {
  $newVHDPath = Join-Path -Path 'e:\hyper-v\VirtualHardDisks' -ChildPath "$i\sysvol.vhdx"
  $param = @{
    Path      = $newVHDPath
    SizeBytes = 20GB
    Dynamic   = $false
    Confirm   = $false
  }
  New-VHD @param
  $param = @{
    VMName             = $i
    Path               = $newVHDPath
    ControllerType     = 'scsi'
    ControllerNumber   = 0
    ControllerLocation = 3
    Confirm            = $false
  }
  Add-VMHardDiskDrive @param
}
foreach ($i in $n) {
  $newVHDPath = Join-Path -Path 'e:\hyper-v\VirtualHardDisks' -ChildPath "$i\ntds.vhdx"
  $param = @{
    Path      = $newVHDPath
    SizeBytes = 20GB
    Dynamic   = $false
    Confirm   = $false
  }
  New-VHD @param
  $param = @{
    VMName             = $i
    Path               = $newVHDPath
    ControllerType     = 'scsi'
    ControllerNumber   = 0
    ControllerLocation = 4
    Confirm            = $false
  }
  Add-VMHardDiskDrive @param
}
foreach ($i in $n) {
  $param = @{
    VMName                       = $i
    StaticMemory                 = $true
    MemoryStartUpBytes           = 2100MB
    AutomaticStartAction         = 'Start'
    AutomaticStopAction          = 'Shutdown'
    AutomaticStartDelay          = 0
    AutomaticCriticalErrorAction = 90
    LockOnDisconnect             = 'on'
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