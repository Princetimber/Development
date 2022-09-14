param location string = resourceGroup().location
@description('virtualnetwork name suffix')
param suffix string
@description('network security groups name suffix')
param nsgsuffix string
@description('virtual network addressPrefixes')
param addressPrefixes array = [
  '172.16.0.0/16'
]
param subnets array= [
  {
    name:'gatewaySubnet'
    addressPrefix:'172.16.0.0/27'
  }
  {
    name:'azureBastionSubnet'
    addressPrefix:'172.16.1.0/26'
  }
  {
  name:'subnet0'
  addressPrefix: '172.16.2.0/24'
  }
]
param subnetname string = 'subnet0'
@description('specify whether to create new or existing virtual network infrastructure')
@allowed([
  'new'
  'existing'
])
param vnetNewOrExisting string
var name = '${toLower(resourceGroup().name)}${suffix}'
var nsgname = '${toLower(resourceGroup().name)}${nsgsuffix}'
param settings object = {
  location:location
  addressPrefixes: addressPrefixes
}
param serviceEndpoints array = [
 {
  service:'Microsoft.storage'
 }
 {
  service:'Microsoft.Keyvault'
 }
 {
  service:'Microsoft.AzureActiveDirectory'
 }
]
resource nsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' existing ={
  name: nsgname
}
var nsgId = nsg.id
resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' =if(vnetNewOrExisting =='new') {
  name:name
  location:location
  tags:{
    DisplayName:'Virtual Networks'
    CostCenter:'Engineering'
  }
  properties:{
    addressSpace:{
      addressPrefixes:settings.addressPrefixes
    }
    subnets:[for subnet in subnets:{
      name:subnet.name
      properties:{
        addressPrefix:subnet.addressPrefix
        serviceEndpoints:serviceEndpoints
        privateEndpointNetworkPolicies:'Enabled'
        privateLinkServiceNetworkPolicies:'Enabled'
      }
    }]
    enableDdosProtection:false
    enableVmProtection:false
  }
}
output name string = vnet.name
output Id string = vnet.id
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01'= {
  name: subnetname
  parent:vnet
  properties:{
    addressPrefix:'172.16.2.0/24'
    networkSecurityGroup:{
      id:nsgId
    }
  }
}