function Start-VirtualMachine {
  [CmdletBinding(DefaultParameterSetName = 'Start', ConfirmImpact = 'Medium', PositionalBinding = $true, SupportsShouldProcess = $true)]
  param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "VM name to start.")][ValidateNotNullOrEmpty()][ValidateScript({
        If (!(Get-VM -Name $_ -ErrorAction SilentlyContinue)) {
          throw "The virtual machine with the name $Name does not exist."
        }
        $true
      })][string]$Name,
    [Parameter(ParameterSetName = 'Start', Mandatory = $true, Position = 1, HelpMessage = "Required to start VM.")][switch]$Start,
    [Parameter(Mandatory = $false, HelpMessage = "If specified, the function will not prompt for confirmation.")][switch]$Force
  )
  if ([string]::IsNullOrEmpty($Name)) {
    throw "The virtual machine name is required."
  }
  switch ($PSCmdlet.ParameterSetName) {
    'Start' {
      if ($start.IsPresent -and $Force.IsPresent -or $PSCmdlet.ShouldProcess($Name, "Start virtual machine")) {
        Get-VM -Name $Name | Start-VM -Confirm:$false
      }
      elseif ($Force -and $PSCmdlet.ShouldContinue("Do you want to start the virtual machine $Name?", "Start virtual machine")) {
        Get-VM -Name $Name | Start-VM
      }
    }
  }
}