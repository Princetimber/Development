<#
.SYNOPSIS
Creates a new storage pool, virtual disk, volume, and sets NTFS permissions.

.DESCRIPTION
The new-storage function creates a storage pool on the first available physical disk,
creates a virtual disk on the storage pool with maximum size, initializes the disk,
creates a partition with maximum size, formats the partition with NTFS file system,
sets NTFS permissions to allow full control for everyone, and creates a hidden directory
within the volume.

.PARAMETER storagePoolFriendlyName
The friendly name for the storage pool.

.PARAMETER virtualHardDiskFriendlyName
The friendly name for the virtual hard disk.

.PARAMETER volumeName
The name for the volume.

.PARAMETER directoryName
The name for the hidden directory to be created within the volume.

.EXAMPLE
new-storage -storagePoolFriendlyName "MyStoragePool" -virtualHardDiskFriendlyName "MyVirtualDisk" -volumeName "MyVolume" -directoryName "MyHiddenDirectory"
Creates a new storage pool named "MyStoragePool", a virtual hard disk named "MyVirtualDisk",
a volume named "MyVolume", and a hidden directory named "MyHiddenDirectory" within the volume.

.NOTES
This function requires administrative privileges.
#>
function new-storage {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [string]$storagePoolFriendlyName,
    [Parameter(Mandatory = $true)]
    [string]$virtualHardDiskFriendlyName,
    [Parameter(Mandatory = $true)]
    [string]$volumeName,
    [Parameter(Mandatory = $false)]
    [string]$directoryName
  )
  $disks = Get-PhysicalDisk -CanPool $true
  if ($disks.Count -eq 0) {
    throw "No disks available to create storage pool"
  }
  if ($disks.Count -ge 1) {
    #create storage pool on the first disk
    $disk = $disks | Select-Object -First 1
    $storageSubsystemFriendlyName = (Get-StorageSubSystem).FriendlyName
    New-StoragePool -FriendlyName $storagePoolFriendlyName -StorageSubSystemFriendlyName $storageSubsystemFriendlyName -PhysicalDisks $disk
    #create virtual disk on the storage pool using the first disk and maxmimum size
    New-VirtualDisk -StoragePoolFriendlyName $storagePoolFriendlyName -FriendlyName $virtualHardDiskFriendlyName -UseMaximumSize -ProvisioningType Fixed -ResiliencySettingName Simple -MediaType SSD
    #create volume on the virtual disk
    $number = (Get-VirtualDisk -FriendlyName $virtualHardDiskFriendlyName | Get-Disk).Number
    #initialize disk
    Initialize-Disk -Number $number -PartitionStyle GPT
    #create partition
    New-Partition -DiskNumber $number -UseMaximumSize -AssignDriveLetter
    #format partition
    $driveLetter = (Get-Partition -DiskNumber $number | Where-Object { $_.Type -EQ "Basic" }).DriveLetter
    Format-Volume -DriveLetter $driveLetter -FileSystem NTFS -NewFileSystemLabel $volumeName -Confirm:$false
    #return Volume label and drive letter
    return (Get-Volume).FileSystemLabel + " " + (Get-Partition -DiskNumber $number).DriveLetter
    #add NTFS permissions to the volume
    $acl = Get-Acl -Path $driveLetter
    $acl.SetAccessRuleProtection($true, $false)
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "FullControl", "Allow")
    $acl.AddAccessRule($rule)
    Set-Acl -Path $driveLetter -AclObject $acl
    #create a hidden directory
    if (!$directoryName) {
      throw "No directory name specified"
    }
    $path = Join-Path -Path $driveLetter -ChildPath $directoryName
    New-Item -Name $directoryName -Path $path -ItemType Directory | ForEach-Object { $_.Attributes = "Hidden" }
  }
}