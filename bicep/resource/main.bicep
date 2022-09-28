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
    objectId:''//ToDO add AzureAD user objectId
    publicIpAddress:''//ToDo add publicIp Address that can access vault
  }
  dependsOn: [
    vnet
  ]
}
output vaultName string = vault.outputs.name
module secrets 'secrets.bicep'={
  name: 'deploySecrets'
  params: {
    name:'' //ToDo add secrets Name
    value:''//ToDO add the value of your secret
    exp:10 // TODO add the UNIX time in secs for the secret to expire
    nbf:12 // TODO add the UNIX time in secs before the secret becomes active
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
