$cert = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object Subject -EQ "CN=*.intheclouds365.com"
$certValue = [System.Convert]::ToBase64String($cert.GetRawCertData())

$param = @{
  DisplayName = 'Microsoft365DSC'
  CertValue   = $certValue
  EndDate     = $cert.NotAfter
  StartDate   = $cert.NotBefore
}
$spn = New-AzADServicePrincipal @param