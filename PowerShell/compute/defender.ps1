$n = @("private", "public")
$n | ForEach-Object -Parallel { Set-NetFirewallProfile -Name $_ -Enabled True -DefaultInboundAction Block -DefaultOutboundAction Allow -AllowInboundRules True -AllowLocalFirewallRules True -AllowUnicastResponseToMulticast True -NotifyOnListen False -LogAllowed False -LogBlocked True -LogIgnored False -LogMaxSizeKilobytes 4096 -PassThru }
$n = (Get-NetAdapter | Where-Object Name -NotLike "Bluetooth Network Connection").Name
$n | ForEach-Object -Parallel { Set-NetConnectionProfile -Name $_ -NetworkCategory Private -PassThru }
Set-MpPreference -CheckForSignaturesBeforeRunningScan $true -CloudBlockLevel Default -CloudExtendedTimeout 50 `
  -DisableCatchupQuickScan $true -DisableCatchupFullScan $true -DisableRemovableDriveScanning $true `
  -DisableScanningMappedNetworkDrivesForFullScan $true -EnableControlledFolderAccess Enabled `
  -EnableDnsSinkhole $true -EnableLowCpuPriority $false -EngineUpdatesChannel staged `
  -HighThreatDefaultAction Block -LowThreatDefaultAction Quarantine -ModerateThreatDefaultAction Quarantine -SevereThreatDefaultAction Block `
  -MAPSReporting Advanced -PlatformUpdatesChannel Staged -QuarantinePurgeItemsAfterDelay 30 `
  -PUAProtection Enabled -RealTimeScanDirection Both -RemediationScheduleDay Never -ScanParameters Quick -ScanAvgCPULoadFactor 50 `
  -ScanOnlyIfIdleEnabled $false -ScanScheduleDay Everyday -ScanScheduleTime 600 -SignatureFallbackOrder MicrosoftUpdateServer `
  -SignatureBlobUpdateInterval 60 -SignatureUpdateInterval 4 -SubmitSamplesConsent SendAllSamples `
  -UnknownThreatDefaultAction Quarantine -AllowSwitchToAsyncInspection $true