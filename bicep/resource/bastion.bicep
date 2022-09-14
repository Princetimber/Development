param location string = resourceGroup().location
param suffix string = 'bastion'
param vnetSuffix string = 'vnet'
param pubIpName string = 'pubIp'
var vnetName = '${toLower(resourceGroup().name)}${vnetSuffix}'
var name = '${vnetName}-${suffix}'
resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnetName
}
var vnetId = vnet.id
var azureBastionSubnetId = '${vnetId}/subnets/azureBastionSubnet'
resource pubIp 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: pubIpName
  location:location
  properties:{
    publicIPAddressVersion:'IPv4'
    publicIPAllocationMethod:'Static'
    idleTimeoutInMinutes:4
  }
  sku:{
    name:'Standard'
    tier:'Regional'
  }
}
resource bastion 'Microsoft.Network/bastionHosts@2022-01-01' = {
  name: name
  location:location
  tags:{
    DisplayName:'Azure Bastion'
    CostCenter: 'Engineering'
  }
  properties:{
  enableFileCopy:true
  disableCopyPaste:false
  enableTunneling:true
  enableIpConnect:true
  enableShareableLink:true
  ipConfigurations:[
   {
  name:'IpConfigurations'
  properties:{
  publicIPAddress:{
    id:pubIp.id
  }
  subnet:{
  id:azureBastionSubnetId
  }
  privateIPAllocationMethod:'Dynamic'
  }
   }
  ]
  }
}
output name string = bastion.name
output bastionId string = bastion.id
