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
param sku string
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
var vnetName = '${toLower(replace(resourceGroup().name,'rg',''))}${vnetsuffix}'
resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnetName
}
var name = '${uniqueString(resourceGroup().id)}${suffix}'
resource stga 'Microsoft.Storage/storageAccounts@2022-05-01' = if (stgNewOrExisting == 'new') {
  name:name
  location:location
  sku:{
    name: sku
  }
  kind:kind
  tags:{
    DisplayName:'Storage Account'
    CostCenter:'Engineering'
  }
  properties:{
    accessTier:accessTier
    allowBlobPublicAccess:true
    allowCrossTenantReplication:true
    allowedCopyScope:'AAD'
    allowSharedKeyAccess:true
    minimumTlsVersion:'TLS1_2'
    supportsHttpsTrafficOnly:true
    isHnsEnabled:true
    isLocalUserEnabled:true
    isNfsV3Enabled:true
    isSftpEnabled: true
    largeFileSharesState:'Enabled'
    defaultToOAuthAuthentication:true
    dnsEndpointType:'Standard'
    networkAcls:{
      defaultAction: 'Deny'
      bypass:'AzureServices'
      virtualNetworkRules:[
        {
          id:'${vnet.id}/subnets/gatewaySubnet'
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
    keyPolicy:{
      keyExpirationPeriodInDays: 90
    }
    sasPolicy:{
      expirationAction: 'Log'
      sasExpirationPeriod:'30:00:00:00'
    }
  }
}
output name string = stga.name
output id string = stga.properties.primaryEndpoints.blob
