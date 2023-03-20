Function Stop-AllRunningVM{
  [cmdletbinding()]
  Param(
    [Parameter(Mandatory=$false)]
    [string]$VMName,
    [Parameter(Mandatory=$false)]
    [Switch]$IncludingHost
  )
  Get-VM | where-object {$_.state -eq 'Running'} | Stop-VM -Passthru -Force
  if ($IncludingHost) {
    Stop-Computer -Force
  }else {
    Write-Output "Host will not be stopped"
    Write-Output "To stop the host, run Stop-AllRunningVM -IncludingHost"
    Write-Output "All running VMs have been stopped"
  }
}