Function Stop-AllRunningVM{
  [cmdletbinding()]
  Param(
    [Parameter(Mandatory=$false)]
    [string]$VMName,
    [Parameter(Mandatory=$false)]
    [Switch]$StopHost
  )
  $VMName = Get-VM | Where-object {$_.State -eq "Running"} | Select-Object -ExpandProperty Name
  Stop-VM -Name $VMName -Passthru -Force
  if ($StopHost.IsPresent) {
    Stop-Computer -Force
  }else {
    Write-Host "All VMs have been stopped."
  }
}