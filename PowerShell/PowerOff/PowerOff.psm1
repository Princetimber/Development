<#
.SYNOPSIS
  Stop all running VMs and optionally the host
.DESCRIPTION
  This function will stop all running VMs and optionally the host.
.PARAMETER VMName
  The name of the VM to stop
.PARAMETER All
  When this switch is used, all running VMs will be stopped
.PARAMETER IncludingHost
  When this switch is used, the host will be stopped
.NOTES
  Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
  Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
  Stop-VirtualMachine -VMName 'VM1'
  Checks if VM1 is running, if so, stops it.
.EXAMPLE
  Stop-VirtualMachine -All
  Checkes if any VMs are running, if so, stops them.
.EXAMPLE
  Stop-VirtualMachine -IncludingHost
  Checks if any VMs are running, if so, stops them and then stops the host.
#>
function Stop-VirtualMachine {
  [CmdletBinding(DefaultParameterSetName = 'All', ConfirmImpact = 'Medium', SupportsShouldProcess = $true)]
  Param(
    [Parameter(Mandatory = $false, Position = 3, HelpMessage = "Enter the name of the VM to be stopped.")][ValidateScript({
        If (Get-VM -Name $_ -ErrorAction SilentlyContinue) {
          $true
        }
        else {
          throw "The virtual machine with the name $Name does not exist."
        }
      })][string]$Name,
    [Parameter(ParameterSetName = 'All', Mandatory = $false, Position = 0, HelpMessage = "Stops all running VMs.")][switch]$All,
    [Parameter(ParameterSetName = 'IncludingHost', Mandatory = $false, Position = 1, HelpMessage = "Stops all running VMs and the VMHost.")][switch]$IncludingHost,
    [Parameter(ParameterSetName = 'VirtualMachine', Mandatory = $false, Position = 2, HelpMessage = "Stops a single machine.")][switch]$VirtualMachine,
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
      }
      elseif ($Force.IsPresent -or $PSCmdlet.ShouldProcess($Name, "Stop Virtual Machine")) {
        if ((Get-VM -Name $Name).State -eq 'Running') {
          Get-VM -Name $Name | Stop-VM | Out-Null
        }
      }
      else {
        Write-Warning "Virtual Machine $Name is not stopped."
      }

    }
    'All' {
      if ($Force.IsPresent -and $PSCmdlet.ShouldContinue("Are you sure you want to stop all running virtual machines?", "Confirm Stop Virtual Machines")) {
        if ((Get-VM).State -eq 'Running') {
          Get-VM | Where-Object { $_.State -eq 'Running' } | Stop-VM -Force | Out-Null
        }
      }
      elseif ($Force.IsPresent -or $PSCmdlet.ShouldProcess($VM, "Stop Virtual Machines")) {
        if ((Get-VM).State -eq 'Running') {
          Get-VM | Where-Object { $_.State -eq 'Running' } | Stop-VM -Force | Out-Null
        }
      }
      else {
        Write-Warning "The virtual machine $VM is running."
      }
    }
    'IncludingHost' {
      if ($Force.IsPresent -or $PSCmdlet.ShouldProcess($VM, "Stop Virtual Machines and Host")) {
        if ((Get-VM).State -ne 'Off') {
          Get-VM | Where-Object { $_.State -eq 'Running' } | Stop-VM -Force | Out-Null
          Stop-Computer -Force
        }
        if ((Get-VM).State -eq 'Off') {
          Stop-Computer -Force
        }
      }
      elseIf ($Force.IsPresent -and $PSCmdlet.ShouldContinue("Are you sure you want to stop all running virtual machines and the host?", "Confirm Stop Virtual Machines and Host")) {
        if ((Get-VM).State -ne 'Off') {
          Get-VM | Where-Object { $_.State -eq 'Running' } | Stop-VM -Force | Out-Null
          Stop-Computer -Force
        }
        if ((Get-VM).State -eq 'Off') {
          Stop-Computer -Force
        }
      }
      else {
        Write-Warning "The virtual machine $VM is running and the VMHost $env:COMPUTERNAME is also running."
        return
      }
    }
  }
}
