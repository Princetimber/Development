$app = Get-AzADApplication -DisplayName 'CAP365'
if (-not $app) {
  try {
    $param = @{
      DisplayName    = 'CAP365'
      Homepage       = "https://cap365app.intheclouds365.com"
      IdentifierUris = "https://cap365app.intheclouds365.com"
    }
    New-AzADApplication @param
  }
  catch {
    Write-Verbose $PSItem.Exception.Message -Verbose
  }
}
$param = @{
  ClientId              = (Get-AzADApplication -DisplayName "CAP365").AppId
  TenantId              = "1384d15a-031b-418c-b134-46c614e3bc4e"
  CertificateThumbprint = (Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object Subject -EQ "CN=*.intheclouds365.com").Thumbprint
}
Connect-MgGraph @param