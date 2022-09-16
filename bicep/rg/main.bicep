targetScope = 'subscription'
param location string = deployment().location
module rg 'rg.bicep'= {
  name: 'deployResourceGroup'
  params: {
    name: ''//enter resource group name
    location: location
  }
}
output rgid string = rg.outputs.rgId
output rgName string = rg.outputs.rgName
