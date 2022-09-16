param location string = resourceGroup().location
param suffix string
param pubIpSuffix string
param subnetName string = 'subnet0'
param vnetnamesuffix string = 'vnet'
param nsgsuffix string = 'nsg'
var nsgName = '${toLower(resourceGroup().name)}${nsgsuffix}'
var vnetname = '${toLower(resourceGroup().name)}${vnetnamesuffix}'
resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnetname
}
resource nsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' existing = {
  name: nsgName
}
var nsgId = nsg.id
var name = '${toLower(resourceGroup().name)}${suffix}'
var pubIpName = '${name}${pubIpSuffix}'
resource pubIp 'Microsoft.Network/publicIPAddresses@2022-01-01'={
  name:pubIpName
  location:location
  properties:{
    publicIPAddressVersion:'IPv4'
    publicIPAllocationMethod:'Static'
    idleTimeoutInMinutes:4
  }
  sku:{
    name:'Standard'
  }
}
resource ngw 'Microsoft.Network/natGateways@2022-01-01' = {
  name:name
  location:location
  sku:{
    name:'Standard'
  }
  properties:{
    publicIpAddresses:[
      {
        id:pubIp.id
      }
    ]
  }
  tags:{
    DisplayName:'NatGateway'
    CostCenter:'Engineering'
  }
}
output Id string = ngw.id
output Name string = ngw.name
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = {
  name: subnetName
  parent:vnet
  properties:{
    addressPrefix:'172.16.2.0/24'
    serviceEndpoints:[
      {
      service:'Microsoft.KeyVault'
      }
      {
      service:'Microsoft.Storage'
      }
      {
      service:'Microsoft.AzureActiveDirectory'
      }
      {
      service:'Microsoft.sql'
      }
      {
      service:'Microsoft.web'
      }
      {
      service:'Microsoft.ContainerRegistry'
      }
    ]
    natGateway:{
      id:ngw.id
    }
    networkSecurityGroup:{
      id:nsgId
    }
  }
}
