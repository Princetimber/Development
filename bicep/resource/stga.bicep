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
var vnetName = '${toLower(resourceGroup().name)}${vnetsuffix}'
resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnetName
}
var vnetId = vnet.id
var gatewaySubnetId = '${vnetId}/subnets/gatewaySubnet'
var subnetId = '${vnetId}/subnets/subnet0'
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
    azureFilesIdentityBasedAuthentication:{
      directoryServiceOptions: 'AD'
    }
    minimumTlsVersion:'TLS1_2'
    supportsHttpsTrafficOnly:true
    isNfsV3Enabled:true
    isHnsEnabled:true
    largeFileSharesState:'Enabled'
    isLocalUserEnabled:true
    isSftpEnabled:true
    defaultToOAuthAuthentication:true
    dnsEndpointType:'AzureDnsZone'
    networkAcls:{
      defaultAction: 'Deny'
      bypass:'AzureServices'
      virtualNetworkRules:[
       {
        id: gatewaySubnetId
        action:'Allow'
        state:'Succeeded'
       }
       {
        id: subnetId
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
    encryption:{
      keySource: 'Microsoft.Keyvault'
    }
  }
  identity:{
    type: 'SystemAssigned'
  }
}
output name string = stga.name
output id string = stga.properties.primaryEndpoints.blob
