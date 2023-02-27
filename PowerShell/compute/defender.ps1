$n = @("private", "public")
$n | ForEach-Object -Parallel { Set-NetFirewallProfile -Name $_ -Enabled True -DefaultInboundAction Block -DefaultOutboundAction Allow -AllowInboundRules True -AllowLocalFirewallRules True -AllowUnicastResponseToMulticast True -NotifyOnListen False -LogAllowed False -LogBlocked True -LogIgnored False -LogMaxSizeKilobytes 4096 -PassThru }
$n = (Get-NetAdapter).Name
$n | ForEach-Object -Parallel { Set-NetConnectionProfile -InterfaceAlias $_ -NetworkCategory Private -PassThru }
Set-MpPreference -CheckForSignaturesBeforeRunningScan $true -CloudBlockLevel Default -CloudExtendedTimeout 50 `
  -DisableCatchupQuickScan $true -DisableCatchupFullScan $true -DisableRemovableDriveScanning $true `
  -DisableScanningMappedNetworkDrivesForFullScan $true -EnableControlledFolderAccess Enabled `
  -EnableDnsSinkhole $true -EnableLowCpuPriority $false -EngineUpdatesChannel staged `
  -HighThreatDefaultAction Block -LowThreatDefaultAction Quarantine -ModerateThreatDefaultAction Quarantine -SevereThreatDefaultAction Block `
  -MAPSReporting Advanced -PlatformUpdatesChannel Staged -QuarantinePurgeItemsAfterDelay 30 `
  -PUAProtection Enabled -RealTimeScanDirection Both -RemediationScheduleDay Never -ScanParameters Quick -ScanAvgCPULoadFactor 50 `
  -ScanOnlyIfIdleEnabled $false -ScanScheduleDay Everyday -ScanScheduleTime 10:00:00 -SignatureFallbackOrder MicrosoftUpdateServer `
  -SignatureBlobUpdateInterval 60 -SignatureUpdateInterval 4 -SubmitSamplesConsent SendAllSamples `
  -UnknownThreatDefaultAction Quarantine -AllowSwitchToAsyncInspection $true -DisableEmailScanning $false -EnableNetworkProtection Enabled -DisableNetworkProtectionPerfTelemetry $false
$n = @('File and Printer Sharing*', 'Remote Event*', 'Remote Schedule*', 'Remote Service*', 'Remote Volume*', 'Windows Defender Fire*', 'Windows Management*', 'Windows Remote*')
$n | ForEach-Object -Parallel { Set-NetFirewallRule -DisplayGroup $_ -Enabled True -Action Allow -Profile Private -Direction Inbound -PassThru }
$id = @("56a863a9-875e-4185-98a7-b882c64b5ce5", "7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c", "d4f940ab-401b-4efc-aadc-ad5f3c50688a", "9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2", "be9ba2d9-53ea-4cdc-84e5-9b1eeee46550", "5beb7efe-fd9a-4556-801d-275e5ffc04cc", `
    "d3e037e1-3eb8-44c8-a917-57927947596d", "3b576869-a4ec-4529-8536-b80a7769e899", "75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84", "26190899-1602-49e8-8b27-eb1d0a1ce869", "d1e49aac-8f56-4280-b9ba-993a6d77406c", "b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4", "92e97fa1-2edf-4476-bdd6-9dd0b4dddc7b", "c1db55ab-c21a-4637-bb3f-a12568109d35")
$id | ForEach-Object -Parallel { Add-MpPreference -AttackSurfaceReductionRules_Ids $_ -AttackSurfaceReductionRules_Actions Enabled }
$id = @("e6db77e5-3df2-4cf1-b95a-636979351e5b", "01443614-cd74-433a-b99e-2ecdc07bfc25")
$id | ForEach-Object -Parallel { Add-MpPreference -AttackSurfaceReductionRules_Ids $_ -AttackSurfaceReductionRules_Actions audit }
$n = @('Beyond Compare 4\BCompare.exe', 'git\bin\git.exe', 'google\chrome\application\chrome.exe', 'greenshot\greenshot.exe', 'Microsoft VS Code\code.exe', 'Mozilla FireFox\firefox.exe', 'Mythicsoft\Agent Ransack\agentRansack.exe', 'notepad++\notepad++.exe', 'powershell\7\pwsh.exe', 'PowerToys\powertoys.exe')
$path = $n | ForEach-Object -Parallel { Join-Path -Path $env:ProgramFiles -ChildPath $_ }
$path | ForEach-Object -Parallel { Add-MpPreference -AttackSurfaceReductionOnlyExclusions $_ }
$path | ForEach-Object -Parallel { Add-MpPreference -ControlledFolderAccessAllowedApplications $_ }