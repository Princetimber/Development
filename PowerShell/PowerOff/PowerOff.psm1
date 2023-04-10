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
  Stop the VM named 'VM1'
.EXAMPLE
  Stop-VirtualMachine -IncludingHost
  Stop all running VMs and the host.
.EXAMPLE
  Stop-VirtualMachine -All
  Stop all running VMs.
.EXAMPLE
  Stop-VirtualMachine -All -IncludingHost
  Stop all running VMs and the host.
#>
Function stop-VirtualMachine {
  [cmdletbinding()]
  Param(
    [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Enter the name of the virtual machine to be stopped", Position = 0)][string]$VMName,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][Switch]$All,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 2)][Switch]$IncludingHost
  )
  $MachineName = $env:COMPUTERNAME
  if ($VMName) {
    Get-VM -Name $VMName | Stop-VM -Passthru -Force
  }
  elseif ($All.IsPresent) {
    Get-VM | Where-Object { $_.state -eq 'Running' } | Stop-VM -Passthru -Force
  }
  elseif ($IncludingHost.IsPresent) {
    Stop-Computer -Force
  }
  elseif ($All.IsPresent -and $IncludingHost.IsPresent) {
    Get-VM | Where-Object { $_.state -eq 'Running' } | Stop-VM -Passthru -Force;
    Stop-Computer -Force
  }
  else {
    Write-Output "$VMName has been stopped"
    Write-Output "$MachineName will be stopped"
  }
}
