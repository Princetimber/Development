<#
.SYNOPSIS
  This function is used to create a storage pool, virtual disk and volume. It takes 5 parameters, FriendlyName, VirtualDiskFriendlyName, CreatePool, CreateVirtualDisk and CreateVolume. The first 2 parameters are mandatory and the rest are switches.
.DESCRIPTION
  This function is used to create a storage pool, virtual disk and volume. It takes 5 parameters, FriendlyName, VirtualDiskFriendlyName, CreatePool, CreateVirtualDisk and CreateVolume. The first 2 parameters are mandatory and the rest are switches.
.PARAMETER FriendlyName
  FriendlyName of the storage pool to be created.
.PARAMETER VirtualDiskFriendlyName
  FriendlyName of the virtual disk to be created.
.PARAMETER DriveLetter
  Drive letter to be assigned to the volume.
.PARAMETER CreatePool
  Switch to create a storage pool.
.PARAMETER CreateVirtualDisk
  Switch to create a virtual disk.
.PARAMETER CreateVolume
  Switch to create a volume.
.INPUTS
  System.String
.OUTPUTS
  System.String
.NOTES
  Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
  Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
  New-Storage -FriendlyName "StoragePool1" -VirtualDiskFriendlyName "VirtualDisk1" -DriveLetter "D" -CreatePool -CreateVirtualDisk -CreateVolume
  This command will create a storage pool, virtual disk and volume.
#>


Function New-Storage {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][string]$FriendlyName,
    [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][string]$VirtualDiskFriendlyName,
    [Parameter(Mandatory = $true, Position = 2, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string]$DriveLetter,
    [Parameter(Mandatory = $true, Position = 3, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string]$FileSystemLabel,
    [Parameter(Mandatory = $true, Position = 4, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][switch]$CreatePool,
    [Parameter(Mandatory = $true, Position = 5, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][switch]$CreateVirtualDisk,
    [Parameter(Mandatory = $true, Position = 6, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][switch]$CreateVolume
  )
  if ([string]::IsNullOrEmpty($FriendlyName)) {
    Write-Error "FriendlyName cannot be null or empty"
  }
  if ([string]::IsNullOrEmpty($VirtualDiskFriendlyName)) {
    Write-Error "VirtualDiskFriendlyName cannot be null or empty"
  }
  $Drive = (Get-Volume -DriveLetter $DriveLetter).DriveLetter
  if ($Drive) {
    Write-Error "$DriveLetter is already in use"
  }
  $physicalDisks = Get-PhyicalDisk -CanPool $true | Select-Object -First 1
  $StorageSubSystemFriendlyName = (Get-StorageSubSystem).FriendlyName
  begin {
    $StoragePool = Get-StoragePool -FriendlyName $FriendlyName
    if ($StoragePool) {
      Write-Error "StoragePool with FriendlyName $FriendlyName already exists"
    }
    elseIf ($CreatePool.IsPresent -and $CreateVirtualDisk.IsPresent -and $CreateVolume.IsPresent -and !$StoragePool) {
      Write-Host "Creating Storage Pool"
      $Pool = @{
        FriendlyName                 = $FriendlyName
        PhysicalDisks                = $physicalDisks
        StorageSubSystemFriendlyName = $StorageSubSystemFriendlyName
      }
      New-StoragePool @Pool
      Write-Host "StoragePool $FriendlyName is created"
      Start-Sleep -Milliseconds 600
      Write-Host "Creating Virtual Disk..."
      $storagePoolFriendlyName = (Get-StoragePool).FriendlyName
      $Disk = @{
        FriendlyName            = $VirtualDiskFriendlyName
        StoragePoolFriendlyName = $storagePoolFriendlyName
        ProvisioningType        = "Thin"
        ResiliencySettingName   = "Simple"
        UseMaximumSize          = $true
      }
      New-VirtualDisk @Disk
      Write-Host "Virtual Disk $FriendlyName is created"
      Start-Sleep -Milliseconds 600
      Write-Host "initializing disk..."
      $number = (Get-VirtualDisk -FriendlyName $VirtualDiskFriendlyName | Get-Disk).Number
      Initialize-Disk -Number $number -PartitionStyle GPT
      Write-Host "Disk $number is initialized"
      Start-Sleep -Milliseconds 600
      Write-Host "Creating partition..."
      $Partition = @{
        DiskNumber     = $number
        UseMaximumSize = $true
        DriveLetter    = $DriveLetter
      }
      New-Partition @Partition
      Write-Host "Partition is created"
      Start-Sleep -Milliseconds 600
      Write-Host "Formatting partition..."
      $volume = @{
        DriveLetter        = $DriveLetter
        FileSystem         = "NTFS"
        NewFileSystemLabel =
        Confirm            = $false
      }
      Format-Volume @volume
      Write-Host "Partition is formatted"
    }
  }
  end {
    Write-Host "Storage Pool $FriendlyName is created"
  }
}