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
  ClientId              = "d9bc4237-d021-455d-9c7d-5523c84f00b8"
  TenantId              = "1384d15a-031b-418c-b134-46c614e3bc4e"
  #Scopes = "AuditLog.Read.All","Directory.Read.All","user.Read.all"
  CertificateThumbprint = (Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object Subject -EQ "CN=*.intheclouds365.com").Thumbprint
}
Connect-MgGraph @param