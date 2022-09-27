@description('specifiy secret name')
param name string
@description('specify secret value')
@secure()
param value string
param exp int
param nbf int
param kvsuffix string = 'kv'
var keyvaultName = '${toLower(replace(resourceGroup().name,'rg',''))}${kvsuffix}'
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyvaultName
}
resource secret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: name
  properties: {
    attributes:{
      enabled: true
      exp:exp
      nbf:nbf
    }
    value:value
  }
  parent:keyVault
}
