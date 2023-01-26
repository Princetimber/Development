Install-Module PowerShellGet -Scope CurrentUser -Repository PSGallery -AllowClobber -Force
Install-Module PowerShellGet -Scope CurrentUser -Repository PSGallery -AllowPrerelease -Force
$n = @('az', 'az.tools.predictor', 'azureAD', 'azureADPreview', 'intuneWin32App', 'Microsoft.Graph', 'Microsoft.PowerShell.SecretManagement', 'Microsoft.PowerShell.SecretStore', 'MicrosoftTeams', 'PSScriptAnalyzer', 'PSReadLine', 'ExchangeOnlineManagement')
$n | ForEach-Object -Parallel { Install-PSResource -Name $_ -Repository PSGallery -Scope AllUsers -Quiet }