param location string = resourceGroup().location
param suffix string = 'bastion'
param vnetSuffix string = 'vnet'
param pubIpName string = 'pubIp'
var vnetName = '${toLower(resourceGroup().name)}${vnetSuffix}'
var name = '${vnetName}-${suffix}'
resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnetName
}
param BastionSubnetObject object = {
  name:'azureBastionSubnet'
  subnet:[
    {
      name:'azureBastionSubnet'
      addressPrefix:'172.16.2.0/24'
    }
  ]
}
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = {
  name: BastionSubnetObject.name
  properties:{
    addressPrefix:BastionSubnetObject.addressPrefix
  }
  parent:vnet
}
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
  id:subnet.id
  }
  privateIPAllocationMethod:'Dynamic'
  }
   }
  ]
  }
}
output name string = bastion.name
output bastionId string = bastion.id
