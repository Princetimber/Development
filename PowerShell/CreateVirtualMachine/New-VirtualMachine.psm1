<#
.SYNOPSIS
  This function creates a new virtual machine.
.DESCRIPTION
  This function creates a new virtual machine, using the New-VM cmdlet and the specified parameters.
.NOTES
  Information or caveats about the function e.g. 'This function is not supported in Linux'
.PARAMETER Name
  The name of the virtual machine.
.PARAMETER Path
  The path where the virtual machine will be stored.
.PARAMETER SwitchName
  The name of the virtual switch to which the virtual machine will be connected.
.PARAMETER MemoryStartupSize
  The amount of memory to allocate to the virtual machine.
.PARAMETER newVHDSize
  The size of the virtual hard disk to create.
.PARAMETER Force
  If specified, the function will not prompt for confirmation.
.INPUTS
  Inputs to this function (if any)
.OUTPUTS
  Outputs from this function (if any)
.LINK
  Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
  New-VirtualMachine -Name 'VM01' -Path 'C:\VirtualMachines' -SwitchName 'Internal' -MemoryStartupSize '4GB' -newVHDSize '40GB'
  This example creates a new virtual machine named VM01, with 4GB of memory and a 40GB virtual hard disk.
.EXAMPLE
  New-VirtualMachine -Name 'VM01' -Path 'C:\VirtualMachines' -SwitchName 'Internal' -MemoryStartupSize '4GB' -newVHDSize '40GB' -Force
  This example creates a new virtual machine named VM01, with 4GB of memory and a 40GB virtual hard disk, without prompting for confirmation.
.EXAMPLE
  New-VirtualMachine -Name 'VM01' -Path 'C:\VirtualMachines' -SwitchName 'Internal' -MemoryStartupSize '4GB' -newVHDSize '40GB' -Verbose
  This example creates a new virtual machine named VM01, with 4GB of memory and a 40GB virtual hard disk, and displays verbose output.
#>
Function New-VirtualMachine {
  [CmdletBinding(DefaultParameterSetName = 'Create', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Create')][switch]$Create,
    [Parameter(Mandatory = $true, Position = 0)][ValidateNotNullOrEmpty()][ValidateScript({
        if (-not(Get-VM -Name $_ -ErrorAction SilentlyContinue)) {
          $true
        }
        else {
          throw "A virtual machine with the name '$($_)' already exists."
        }
      })][string]$Name,
    [Parameter(Mandatory = $true, Position = 1)][ValidateNotNullOrEmpty()][ValidateScript({
        if (-not(Test-Path -Path $_ -PathType Container)) {
          throw "The path '$($_)' does not exist."
        }
        else {
          $true
        }
      })][string]$Path,
    [Parameter(Mandatory = $true, Position = 2)][ValidateSet('Datacenter', 'Internal')][ValidateScript({
        if (-not(Get-VMSwitch -Name $_ -ErrorAction SilentlyContinue)) {
          throw "The virtual switch '$($_)' does not exist."
        }
        else {
          $true
        }
      })][string]$SwitchName,
    [Parameter(Mandatory = $false, Position = 3)][ValidateSet("4GB", "8GB", "16GB", "32GB")][string]$MemoryStartupSize = "4GB",
    [Parameter(Mandatory = $false, Position = 4)][ValidateSet("40GB", "80GB", "100GB", "120GB")][string]$newVHDSize = "40GB",
    [Parameter(Mandatory = $false, HelpMessage = "If specified, the function will not prompt for confirmation.")][switch]$Force
  )
  #validate Name parameter is not null or empty
  if ([string]::IsNullOrEmpty($Name)) {
    throw "The name of the virtual machine cannot be null or empty."
  }
  #validate Path parameter is not null or empty
  if ([string]::IsNullOrEmpty($Path)) {
    throw "The path of the virtual machine cannot be null or empty."
  }
  #convert MemoryStartupSize and newVHDSize to GB
  $MemoryStartupSizeInGB = switch ($MemoryStartupSize) {
    "4GB" { 4GB }
    "8GB" { 8GB }
    "16GB" { 16GB }
    "32GB" { 32GB }
  }
  $newVHDSizeInGB = switch ($newVHDSize) {
    "40GB" { 40GB }
    "80GB" { 80GB }
    "100GB" { 100GB }
    "120GB" { 120GB }
  }
  #validate Path parameter
  $VMPath = Join-Path -Path $Path -ChildPath $Name
  $VHDPath = Join-Path -Path (Split-Path -Path $Path) -ChildPath "VirtualHardDisks"
  $NewVHDPath = Join-Path -Path $VHDPath -ChildPath (Join-Path -Path $Name -ChildPath "$Name.vhdx")
  #create the virtual machine
  switch ($PSCmdlet.ParameterSetName) {
    'Create' {
      if ($PSCmdlet.ShouldProcess($Name, 'Create Virtual Machine')) {
        $vmParam = @{
          Name               = $Name
          Path               = $VMPath
          MemoryStartupbytes = $MemoryStartupSizeInGB
          NewVHDPath         = $NewVHDPath
          NewVHDSizebytes    = $newVHDSizeInGB
          SwitchName         = $SwitchName
          Generation         = 2
        }
        New-VM @vmParam
      }
      elseif ($PSCmdlet.ShouldContinue("Do you want to create the virtual machine $Name?", "Create Virtual Machine")) {
        $vmParam = @{
          Name               = $Name
          Path               = $VMPath
          MemoryStartupbytes = $MemoryStartupSizeInGB
          NewVHDPath         = $NewVHDPath
          NewVHDSizebytes    = $newVHDSizeInGB
          SwitchName         = $SwitchName
          Generation         = 2
        }
        New-VM @vmParam
      }
      else {
        Write-Warning "The virtual machine $Name was not created."
      }
    }
  }
}
