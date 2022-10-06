param location string = resourceGroup().location
param suffix string = 'bastion'
param vnetSuffix string = 'vnet'
param pubIpName string = 'pubIp'
var vnetName = '${toLower(replace(resourceGroup().name, 'rg', ''))}${vnetSuffix}'
var name = '${vnetName}-${suffix}'
resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnetName
}
param bastionSubnetName string = 'azureBastionSubnet'
param addressPrefix string = '172.16.1.0/24'
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = {
  name: bastionSubnetName
  properties: {
    addressPrefix: addressPrefix
  }
  parent: vnet
}
resource pubIp 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: pubIpName
  location: location
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
}
resource bastion 'Microsoft.Network/bastionHosts@2022-01-01' = {
  name: name
  location: location
  tags: {
    DisplayName: 'Azure Bastion'
    CostCenter: 'Engineering'
  }
  properties: {
    enableFileCopy: true
    disableCopyPaste: false
    enableTunneling: true
    enableIpConnect: true
    enableShareableLink: true
    ipConfigurations: [
      {
        name: 'IpConfigurations'
        properties: {
          publicIPAddress: {
            id: pubIp.id
          }
          subnet: {
            id: subnet.id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
  sku: {
    name: 'Standard'
  }
}
output name string = bastion.name
output bastionId string = bastion.id
