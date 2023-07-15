@description('resource group location')
param location string = resourceGroup().location
@description('virtual network name suffix')
param vnetNameSuffix string
param vnetName string = '${toLower(replace(resourceGroup().name, 'rg', ''))}${toLower(vnetNameSuffix)}'
@description('network security group name suffix')
param nsgNameSuffix string
param nsgName string = '${toLower(replace(resourceGroup().name, 'rg', ''))}${toLower(nsgNameSuffix)}'
@description('specify to create a new or existing virtual network')
@allowed([
  'new'
  'existing'
])
param vnetNewOrExisting string = 'new'
@description('virtual network settings')
param vnetSettings object = {
  name: vnetName
  location: location
  addressPrefixes: [
    {
      addressPrefix: '175.16.0.0/16'
    }
  ]
  subnets: [
    {
      name: 'subnet1'
      addressPrefix: '175.16.1.0/24'
      serviceEndpoints: [
        {
          Service: 'Microsoft.Storage'
        }
        {
          service: 'Microsoft.Sql'
        }
        {
          service: 'Microsoft.KeyVault'
        }
        {
          service: 'Microsoft.AzureActiveDirectory'
        }
        {
          Service: 'Microsoft.web'
        }
        {
          service: 'Microsoft.Devices'
        }
        {
          Service: 'Microsoft.ContainerRegistry'
        }
      ]
      networkSecurityGroup: {
        id: resourceId('Microsoft.Network/networkSecurityGroups', nsgName)
      }
    }
    {
      name: 'subnet2'
      addressPrefix: '175.16.2.0/24'
      serviceEndpoints: [
        {
          Service: 'Microsoft.Storage'
        }
        {
          service: 'Microsoft.Sql'
        }
        {
          service: 'Microsoft.KeyVault'
        }
        {
          service: 'Microsoft.AzureActiveDirectory'
        }
        {
          Service: 'Microsoft.web'
        }
        {
          service: 'Microsoft.Devices'
        }
        {
          Service: 'Microsoft.ContainerRegistry'
        }
      ]
      networkSecurityGroup: {
        id: resourceId('Microsoft.Network/networkSecurityGroups', nsgName)
      }
    }
  ]
  enableDdosProtection: false
  enableVmProtection: true
  encryption: {
    enabled: true
    enforcement: 'DropUnencrypted'
  }
}
resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' = if (vnetNewOrExisting == 'new') {
  name: vnetSettings.name
  location: vnetSettings.location
  tags: {
    displayName: 'virtual network'
    CostCenter: 'Engineering'
  }
  properties: {
    addressSpace: {
      addressPrefixes: vnetSettings.addressPrefixes.addressPrefix
    }
    subnets: [for subnet in vnetSettings.subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        serviceEndpoints: subnet.serviceEndpoints
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
        networkSecurityGroup: subnet.networkSecurityGroup
      }
    }]
    enableDdosProtection: vnetSettings.enableDdosProtection
    enableVmProtection: vnetSettings.enableVmProtection
    encryption: vnetSettings.encryption
  }
}
