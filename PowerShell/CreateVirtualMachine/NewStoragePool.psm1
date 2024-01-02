<#
.SYNOPSIS
  This function is used to create a storage pool, virtual disk and volume. It takes 5 parameters, FriendlyName, VirtualDiskFriendly, CreateVirtualDisk and CreateVolume. The first 2 parameters are mandatory and the rest are switches.
.DESCRIPTION
  This function is used to create a storage pool, virtual disk and volume. It takes 5 parameters, FriendlyName, VirtualDiskFriendly, CreateVirtualDisk and CreateVolume. The first 2 parameters are mandatory and the rest are switches.
.PARAMETER FriendlyName
  FriendlyName of the storage pool to be created.
.PARAMETER VirtualDiskFriendlyName
  FriendlyName of the virtual disk to be created.
.PARAMETER DriveLetter
  Drive letter to be assigned to the volume.
.PARA
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
  New-Storage -FriendlyName "StoragePool1" -VirtualDiskFriendlyName "VirtualDisk1" -DriveLetter -CreateVirtualDisk -CreateVolume
  This command will create a storage pool, virtual disk and volume.
#>


Function Add-StoragePool {
  [CmdletBinding(DefaultParameterSetName = 'CreatePool', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
  Param(
    [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidateScript({
      if(-not(Get-StoragePool -FriendlyName $_ -ErrorAction SilentlyContinue)) {
        $true
      }
      else {
        throw "Storage pool $_ already exists"
      }
    })][string]$FriendlyName,
    [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'CreatePool')][switch]$CreatePool

  )
  if ([string]::IsNullOrEmpty($FriendlyName)) {
    Write-Error "FriendlyName cannot be null or empty"
  }
  $PD = Get-PhysicalDisk -CanPool:$true | Select-Object -First 1
  $StorageSubSystemFriendlyName = (Get-StorageSubSystem).FriendlyName
  switch ($PSCmdlet.ParameterSetName){
    "CreatePool" {
      if($CreatePool.IsPresent){
        if($PSCmdlet.ShouldProcess($FriendlyName, "Create Storage Pool")){
          New-StoragePool -FriendlyName $FriendlyName -StorageSubSystemFriendlyName $StorageSubSystemFriendlyName -PhysicalDisks $PD
        }
        elseif($PSCmdlet.ShouldContinue("Do you want to create the storagePool $FriendlyName?","Create Storage Pool")){
          New-StoragePool -FriendlyName $FriendlyName -StorageSubSystemFriendlyName $StorageSubSystemFriendlyName -PhysicalDisks $PD
        }
      }
    }
  }
}
Function Add-VirtualDisk {
  [CmdletBinding(DefaultParameterSetName = 'CreateVirtualDisk', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
  param(
    [Parameter(Mandatory = $true, Position = 0)][ValidateScript({
      if(-not(Get-VirtualDisk -FriendlyName $_ -ErrorAction SilentlyContinue)) {
        $true
      }
      else {ucsvc.exe
        throw "Virtual disk $_ already exists"
      }
    })][string]$FriendlyName,
    [Parameter(Mandatory = $true, Position = 1)][ValidateScript({
      if(Get-StoragePool -FriendlyName $_ -ErrorAction SilentlyContinue) {
        $true
      }
      else {
        throw "Storage pool $_ does not exist"
      }
    })][string]$StoragePoolFriendlyName,
    [Parameter(Mandatory = $false, Position = 2)][ValidateSet("Simple", "Mirror", "Parity")][string]$ResiliencySettingName = "Simple",
    [Parameter(Mandatory = $false, Position = 3)][ValidateSet("Fixed", "Thin")][string]$ProvisioningType = "thin",
    [Parameter(Mandatory = $false, Position = 4)][ValidateScript({
      if($_ -gt 0) {
        $true
      }
      else {
        throw "Size must be greater than 0"
      }
    })][int]$Size,
    [Parameter(Mandatory = $true, Position = 6)][switch]$CreateVirtualDisk
  )
  switch ($PSCmdlet.ParameterSetName){
    "CreateVirtualDisk"{
      if($PSCmdlet.ShouldProcess($FriendlyName,"Create Virtual Disk")){
        $splat = @{
          FriendlyName = $FriendlyName
          StoragePoolFriendlyName = $StoragePoolFriendlyName
          ResiliencySettingName = $ResiliencySettingName
          ProvisioningType = $ProvisioningType
          UseMaximumSize = $UseMaximumSize
        }
        if($Size){
          $splat.Add("Size",$Size)
          $splat.Remove("UseMaximumSize",$UseMaximumSize)
        }
        New-VirtualDisk @splat
      }
      elseIf($PSCmdlet.ShouldContinue("Do you want to create the virtual disk $FriendlyName?","Create Virtual Disk")){
        $splat = @{
          FriendlyName = $FriendlyName
          StoragePoolFriendlyName = $StoragePoolFriendlyName
          ResiliencySettingName = $ResiliencySettingName
          ProvisioningType = $ProvisioningType
        }
        if($Size){
          $splat.Add("Size",$Size)
        }
        New-VirtualDisk @splat -UseMaximumSize:$true
      }
    }
  }
}
function Add-Volume {
  [CmdletBinding(DefaultParameterSetName = 'CreateVolume', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
  param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Virtual Disk Friendly Name!")][ValidateScript({
      if(Get-VirtualDisk -FriendlyName $_ -ErrorAction SilentlyContinue) {
        $true
      }
      else {
        throw "Virtual disk $_ does not exist"
      }
    })][string]$FriendlyName,
    [Parameter(Mandatory = $true, Position = 1, HelpMessage = "Drive Letter to be assigned to the volume!")][ValidateScript({
      if($_ -match "^[a-zA-Z]:$") {
        $true
      }
      else {
        throw "Drive letter must be in the format of a letter followed by a colon"
      }
    })][string]$DriveLetter,
    [Parameter(Mandatory = $false, Position = 2, HelpMessage = "File System to be used for the volume!")][ValidateSet("NTFS", "ReFS")][string]$FileSystem = "NTFS",
    [Parameter(Mandatory = $false, Position = 3, HelpMessage = "Use Maximum Size for the volume!")][bool]$UseMaximumSize = $true,
    [Parameter(Mandatory = $false, Position = 4, HelpMessage = "Friendly Name for the volume!")][string]$FileSystemLabel,
    [Parameter(Mandatory = $true, Position = 5, ParameterSetName = 'CreateVolume')][switch]$CreateVolume
  )
  switch ($PSCmdlet.ParameterSetName){
    "CreateVolume"{
      if($PSCmdlet.ShouldProcess($FriendlyName,"Create Volume")){
        # initialize disk
        $number = (Get-VirtualDisk -FriendlyName $FriendlyName | Get-Disk).Number
        Initialize-Disk -Number $number -PartitionStyle GPT
        # create disk partition
        $splat = @{
          DiskNumber = $number
          DriveLetter = $DriveLetter
          UseMaximumSize = $UseMaximumSize
        }
        New-Partition @splat
        # format disk partition
        $splat = @{
          DriveLetter = $DriveLetter
          FileSystem = $FileSystem
          NewFileSystemLabel = $FileSystemLabel
          Confirm = $false
        }
        Format-Volume @splat
      }
    }
  }
}