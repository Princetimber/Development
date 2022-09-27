param location string = resourceGroup().location
@description('storage account name suffix')
param suffix string = 'stga'
@description('storage account skus')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Standard_RAGZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
param sku string = 'Standard_LRS'
@allowed([
  'StorageV2'
  'BlobStorage'
  'BlockBlobStorage'
  'FileStorage'
  'Storage'
])
param kind string = 'StorageV2'
@allowed([
  'Hot'
  'Cool'
])
param accessTier string = 'Hot'
@description('Public IpAddress where storage is accessible over the internet')
param publicIpAddress string
param vnetsuffix string ='vnet'
@description('Specify whether to create a new storage infrastructure or use an existing')
@allowed([
  'new'
  'existing'
])
param stgNewOrExisting string
//param vaultsuffix string ='kv'
//var vaultName = '${toLower(resourceGroup().name)}${vaultsuffix}'
//resource vault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
//name: vaultName
//}
//var vaultUri = vault.properties.vaultUri
//param keyName string = '365CloudCertificateKey'
//resource keys 'Microsoft.KeyVault/vaults/keys@2022-07-01'existing = {
  //name:keyName
//}
//var KeysName = keys.name
//var keyVersion = keys.properties.keyUriWithVersion
var vnetName = '${toLower(replace(resourceGroup().name,'rg',''))}${vnetsuffix}'
resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnetName
}
var name = '${uniqueString(resourceGroup().id)}${suffix}'
resource stga 'Microsoft.Storage/storageAccounts@2021-09-01' = if (stgNewOrExisting == 'new') {
  name: name
  location:location
  tags:{
    displayName:'storageAccounts'
    CostCenter:'Engineering'
  }
  kind:kind
  sku:{
    name: sku
  }
  properties:{
    accessTier:accessTier
    allowBlobPublicAccess:true
    allowCrossTenantReplication:true
    allowedCopyScope:'AAD'
    allowSharedKeyAccess:true
    minimumTlsVersion:'TLS1_2'
    supportsHttpsTrafficOnly:true
    isNfsV3Enabled:true
    isHnsEnabled:true
    largeFileSharesState:'Enabled'
    isLocalUserEnabled:true
    isSftpEnabled:true
    defaultToOAuthAuthentication:true
    dnsEndpointType:'Standard'
    networkAcls:{
      defaultAction: 'Deny'
      bypass:'AzureServices'
      virtualNetworkRules:[
       {
        id: '${vnet.id}/subnets/gatewaySubnet'
        action:'Allow'
        state:'Succeeded'
       }
       {
        id:'${vnet.id}/subnets/subnet0'
        action:'Allow'
        state:'Succeeded'
       }
      ]
      ipRules:[
        {
          value: publicIpAddress
          action:'Allow'
        }
      ]
    }
    immutableStorageWithVersioning:{
      enabled:true
      immutabilityPolicy:{
        allowProtectedAppendWrites:true
        immutabilityPeriodSinceCreationInDays:30
        state:'Unlocked'
      }
    }
    keyPolicy:{
      keyExpirationPeriodInDays: 90
    }
    sasPolicy:{
      expirationAction: 'Log'
      sasExpirationPeriod: '30:00:00:00'
    }
encryption:{
  keySource: 'Microsoft.Keyvault'
  services:{
blob:{
  enabled:true
  keyType:'Service'
}
file:{
  enabled:true
  keyType:'Service'
}
queue:{
  enabled:true
  keyType:'Service'
}
table:{
  enabled:true
  keyType:'Service'
}
  }
}
  }
  identity:{
    type: 'SystemAssigned'
  }
}
output name string = stga.name
output id string = stga.properties.primaryEndpoints.blob
