param location string = resourceGroup().location
module nsg 'nsg.bicep'={
  name:'deployNSG'
  params:{
    location:location
    destinationAddressPrefix: 'VirtualNetwork'
    sourceAddressPrefixes:[
      '10.0.1.0/28'
      '17.16.25.0/28'
    ]
    suffix: 'nsg'
  }
}
output nsgId string = nsg.outputs.nsgId
output nsgName string = nsg.outputs.nsgname
module vnet 'vnet.bicep'={
  name: 'deployvnet'
  dependsOn:[
    nsg
  ]
  params: {
    location:location
    vnetNewOrExisting:'new'
    nsgsuffix:'nsg'
    suffix:'vnet'
  }
}
output vnetName string = vnet.outputs.name
output ventId string = vnet.outputs.Id

module ng 'natgw.bicep'= {
  name: 'deplyNatGateway'
  dependsOn:[
    vnet
  ]
  params: {
    location:location
    pubIpSuffix: 'pubIp'
    suffix:'ng'
  }
}
module keyvault 'keyvaults.bicep'= {
  name: 'deployKeyvault'
  params: {
    location:location
    objectId:''
    publicIpAddress:''
  }
  dependsOn: [
    vnet
  ]
}
