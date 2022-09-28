targetScope = 'subscription'
param location string = deployment().location
module rg 'rg.bicep'= {
  name: 'deployResourceGroup'
  params: {
    name: ''//TODO enter resource group name
    location: location
  }
}
output id string = rg.outputs.rgId
output Name string = rg.outputs.rgName
