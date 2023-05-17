$ManifestSetting = @{
  ModuleVersion              = "1.0.0"
  Guid                       = [guid]::NewGuid()
  Author                     = "Olamide Olaleye"
  CompanyName                = "Intheclouds365 Ltd"
  RootModule                 = "CreateVirtualMachine.psm1"
  Description                = "Creates,Configures, Starts, Stops and Removes Virtual Machines on a hyper-v host"

  FunctionsToExport          = @("New-VirtualMachine", "Set-VMConfigurationSettings", "Stop-VirtualMachine", "Start-VirtualMachine", "Remove-VirtualMachine")
  PowerShellVersion          = "5.1"
  CmdletsToExport            = @("New-VM", "Set-VM", "Stop-VM", "Start-VM", "Remove-VM", "Stop-Computer")
  AliasesToExport            = "*"
  VariablesToExport          = "*"
  RequiredAssemblies         = "System.Management.Automation"
  CompatiblePSEditions       = "Desktop", "Core"
  ProcessorArchitecture      = "Amd64"
  RequireLicenseAcceptance   = $false
  NestedModules              = @("CreateVirtualMachine.psm1")
  FormatsToProcess           = ""
  TypesToProcess             = ""
  Tags                       = "VirtualMachine"
  DefaultCommandPrefix       = ""
  ExternalModuleDependencies = @(
    @{ModuleName = "PowerShellGet"; ModuleVersion = "2.2.5" }
    @{ModuleName = "PackageManagement"; ModuleVersion = "1.4.7" }
  )
}
New-ModuleManifest -Path 'C:\Program Files\PowerShell\Modules\CreateVirtualMachine\CreateVirtualMachine.psd1' @ManifestSetting
New-ModuleManifest -Path 'C:\Development\PowerShell\CreateVirtualMachine\CreateVirtualMachine.psd1' @ManifestSetting
