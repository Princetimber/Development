<#
.SYNOPSIS
  This function will create a new domain controller
.DESCRIPTION
  This function will setup a new domain controller.
  it will create the required dtatbase folders and hide them. It will install the domain controller and configure the DNS server.
  It is using the Install-ADDSForest cmdlet, in the backgroung to create the domain controller.
.PARAMETER DomainName
  The domain name to create
.PARAMETER LogPathName
  The name of the log folder to create
.PARAMETER DatabasePathName
  The name of the database folder to create
.PARAMETER SysvolPathName
  The name of the sysvol folder to create
.PARAMETER SiteName
  The name of the site to create
.PARAMETER NetBiosName
  The netbios name of the domain
.PARAMETER Password
  The password for the domain administrator
.INPUTS
  None
.NOTES
  Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
  Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
  New-DomainController -DomainName "contoso.com" -LogPathName "Logs" -DatabasePathName "NTDS" -SysvolPathName "Sysvol" -SiteName "Default-First-Site-Name" -NetBiosName "contoso" -Password "P@ssw0rd" -Install -Setup
#>
function New-DomainController {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][string]$DomainName,
    [Parameter(Mandatory = $false, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][string]$LogPathName = "Logs",
    [Parameter(Mandatory = $false, Position = 2, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][string]$DatabasePathName = "NTDS",
    [Parameter(Mandatory = $false, Position = 3, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][string]$SysvolPathName = "Sysvol",
    [Parameter(Mandatory = $false, Position = 4, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][string]$SiteName,
    [Parameter(Mandatory = $true, Position = 5, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][string]$NetBiosName = $DomainName.Split('.')[0],
    [Parameter(Mandatory = $true, Position = 6, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][securestring]$Password,
    [Parameter(Mandatory = $false, Position = 7, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][switch]$Install,
    [Parameter(Mandatory = $false, Position = 7, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][switch]$Setup
  )
  if ([string]::IsNullOrEmpty($DomainName)) {
    throw "DomainName is required"
  }
  if ([string]::IsNullOrEmpty($LogPath)) {
    throw "LogPath is required"
  }
  if ([string]::IsNullOrEmpty($DatabasePath)) {
    throw "DatabasePath is required"
  }
  if ([string]::IsNullOrEmpty($SysvolPath)) {
    throw "SysvolPath is required"
  }
  if ([string]::IsNullOrEmpty($SiteName)) {
    throw "SiteName is required"
  }
  if ([string]::IsNullOrEmpty($NetBiosName)) {
    throw "NetBiosName is required"
  }
  $LogPath = If (-not (Test-Path -Path (Join-Path -Path L:\ -ChildPath $LogPathName))) {
    New-Item -Name $logPathName -Path L:\ -ItemType Directory | ForEach-Object { $_.Attributes = "hidden" }
  }
  $DatabasePath = If (-not (Test-Path -Path (Join-Path -Path D:\ -ChildPath $DatabasePathName))) {
    New-Item -Name $DatabasePathName -Path D:\ -ItemType Directory | ForEach-Object { $_.Attributes = "hidden" }
  }
  $SysvolPath = If (-not (Test-Path -Path (Join-Path -Path S:\ -ChildPath $SysvolPathName))) {
    New-Item -Name $SysvolPathName -Path S:\ -ItemType Directory | ForEach-Object { $_.Attributes = "hidden" }
  }
  $SafeModeAdministratorPassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
  if ($Install.IsPresent) {
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
  }
  if ($setUp.IsPresent) {
    $forest = @{
      InstallDNS                    = $true
      DomainName                    = $DomainName
      DomainMode                    = 'WinThreshold'
      ForestMode                    = 'WinThreshold'
      SafeModeAdministratorPassword = $SafeModeAdministratorPassword
      DomainNetBiosName             = $NetBiosName
      DatabasePath                  = $DatabasePath
      LogPath                       = $LogPath
      SysvolPath                    = $SysvolPath
      force                         = $true
    }
    Install-ADDSForest @forest
  }
}