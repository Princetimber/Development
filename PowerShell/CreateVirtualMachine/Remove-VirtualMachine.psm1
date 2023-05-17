<#
.SYNOPSIS
  This function removes a virtual machine and its associated files.
.DESCRIPTION
  This function removes a virtual machine and its associated files.
.PARAMETER Name
  The name of the virtual machine to remove.
.PARAMETER Path
  The path to the virtual machine.
.PARAMETER DiskPath
  The path to the virtual machine disks.
.PARAMETER Remove
  When specified, will execute the Remove-VM cmdlet. and Remove-item cmdlet, which will remove the virtual machine and its associated files.
.PARAMETER Force
  When specified, will not prompt for confirmation.
.NOTES
  Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
  Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
  Remove-VirtualMachine -Name "VM01" -Path "C:\VMs" -DiskPath "C:\VMs\VirtualHardDisks" -Remove -Force
  This example removes the virtual machine VM01 and its associated files.
.EXAMPLE
  Remove-VirtualMachine -Name "VM01" -Path "C:\VMs" -DiskPath "C:\VMs\VirtualHardDisks" -Remove
  This example removes the virtual machine VM01 and its associated files, but prompts for confirmation.
#>
function Remove-VirtualMachine {
  [CmdletBinding(DefaultParameterSetName = 'Remove', PositionalBinding = $true, ConfirmImpact = 'High', SupportsShouldProcess = $true)]
  param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "VM name to remove.")][ValidateNotNullOrEmpty()][ValidateScript({
        If (!(Get-VM -Name $_ -ErrorAction SilentlyContinue)) {
          throw "The virtual machine with the name $Name does not exist."
        }
        $true
      })][string]$Name,
    [Parameter(Mandatory = $false, Position = 1, HelpMessage = "Path to the virtual machine.")][ValidateNotNullOrEmpty()][ValidateScript({
        If (!(Test-Path -Path $_ -PathType Container -ErrorAction SilentlyContinue)) {
          throw "The path container $Path does not exist."
        }
        $true
      })][string]$Path,
    [Parameter(Mandatory = $False, Position = 2, HelpMessage = "Path to VM disks.")][ValidateNotNullOrEmpty()][ValidateScript({
        If (!(Test-Path -Path $_ -PathType Container -ErrorAction SilentlyContinue)) {
          throw "The path container $Path does not exist."
        }
        $true
      })][string]$DiskPath = (Join-Path -Path(Join-Path -Path(Split-Path -Path $Path)-ChildPath "VirtualHardDisks" ) -ChildPath $Name),
    [Parameter(ParameterSetName = 'Remove', Mandatory = $true, Position = 2, HelpMessage = "Required to remove VM.")][switch]$Remove,
    [Parameter(Mandatory = $false, HelpMessage = "If specified, the function will not prompt for confirmation.")][switch]$Force
  )
  if ([string]::IsNullOrEmpty($Name)) {
    throw "The parameter Name is required, and cannot be null or empty."
  }
  if ([string]::IsNullOrEmpty($Path)) {
    throw "The parameter Path is required, and cannot be null or empty."
  }
  $DiskPath = Join-Path -Path(Join-Path -Path(Split-Path -Path $Path)-ChildPath "VirtualHardDisks" ) -ChildPath $Name
  $State = (Get-VM -Name $Name).State
  switch ($PSCmdlet.ParameterSetName) {
    'Remove' {
      if ($Force.IsPresent -or $PSCmdlet.ShouldProcess($Name, "Remove virtual machine")) {
        if ($State) {
          Stop-VM -Name $Name -Force -TurnOff
          Remove-VM -Name $Name -Force
          Remove-Item -Path $DiskPath -Force -Recurse
          Remove-Item -Path(Join-Path -Path $Path -ChildPath $Name) -Force -Recurse

        }
      }
      elseif ($Force.IsPresent -and $PSCmdlet.ShouldContinue("Do you want to remove the virtual machine $Name?", "Remove virtual machine")) {
        if (!$State) {
          Remove-VM -Name $Name -Force
          Remove-Item -Path $DiskPath -Force -Recurse
          Remove-Item -Path(Join-Path -Path $Path -ChildPath $Name) -Force -Recurse
        }
      }
      else {
        Write-Warning "The virtual machine $Name was not removed."
      }
    }
  }
}