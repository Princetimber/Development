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
output vnetId string = vnet.outputs.Id
module vault 'keyvaults.bicep'= {
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
output vaultName string = vault.outputs.name
module secrets 'secrets.bicep'={
  name: 'deploySecrets'
  params: {
    name:''
    value:''
    exp:01
    nbf:01
  }
  dependsOn:[
    vault
  ]
}
output secretName string = secrets.name
module bastion 'bastion.bicep' = {
  name: 'deployBastionInfrastructure'
  params:{
    location:location
  }
  dependsOn:[
    vnet
  ]
}
output bastionName string = bastion.name
