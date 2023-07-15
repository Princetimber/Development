param location string = resourceGroup().location
@description('storage account name suffix')
param suffix string = 'stga'
param name string = '${uniqueString(resourceGroup().id)}${suffix}'
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
param vnetsuffix string = 'vnet'
@description('Specify whether to create a new storage infrastructure or use an existing')
@allowed([
  'new'
  'existing'
])
param stgNewOrExisting string
param vnetName string = '${toLower(replace(resourceGroup().name, 'rg', ''))}${vnetsuffix}'
param stgSettings object = {
  name: name
  location: location
  sku: {
    name: sku
  }
  kind: kind
  properties: {
    accessTier: accessTier
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: true
    allowSharedKeyAccess: true
    allowCrossTenantReplication: true
    minimumTlsVersion: 'TLS1_2'
    isHnsEnabled: true
    isNfsV3Enabled: true
    islocalUserEnabled: true
    largeFileSharesState: 'enabled'
    defaultToOAuthAuthentication: true
    dnsEndpointType: 'Standard'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'subnet1')
          action: 'Allow'
          state: 'Succeeded'
        }
        {
          id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'subnet2')
          action: 'Allow'
          state: 'Succeeded'
        }
      ]
      ipRules: [
        {
          value: publicIpAddress
          action: 'Allow'
        }
      ]
    }
    keyPolicy: {
      keyExpirationPeriodInDays: 90
    }
    sasPolicy: {
      sasExpirationPeriod: '30:00:00:00'
      expirationAction: 'log'
    }
  }
}
resource stg 'Microsoft.Storage/storageAccounts@2022-09-01' = if (stgNewOrExisting == 'new') {
  name: stgSettings.name
  location: stgSettings.location
  sku: stgSettings.sku
  kind: stgSettings.kind
  properties: stgSettings.properties
}
output stgName string = stg.name
output id string = stg.properties.primaryEndpoints.blob
