param location string = resourceGroup().location
param tenantId string = subscription().tenantId
param objectId string //AAD User ObjectId
param suffix string = 'kv'
param vnetsuffix string = 'vnet'
param publicIpAddress string //Enter public IPAddress
var name = '${toLower(resourceGroup().name)}${suffix}'
var vnetName = '${toLower(resourceGroup().name)}${vnetsuffix}'
resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnetName
}
var vnetId = vnet.id
var gatewaySubnetId = '${vnetId}/subnets/gatewaySubnet'
var azureBastionSubnetId = '${vnetId}/subnets/azureBastionSubnet'
var subnetId = '${vnetId}/subnets/Subnet0'

resource keyvaults 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: name
  location:location
  properties: {
    sku: {
      family:'A'
      name:'standard'
    }
    tenantId:tenantId
    enabledForDeployment:true
    enabledForDiskEncryption:true
    enabledForTemplateDeployment:true
    enablePurgeProtection:true
    enableRbacAuthorization:false
    enableSoftDelete:true
    softDeleteRetentionInDays:30
    accessPolicies:[
      {
        objectId: objectId
        permissions: {
        certificates:[
          'all'
        ]
        keys:[
          'all'
        ]
        secrets:[
          'all'
        ]
        storage:[
          'all'
        ]
        }
        tenantId:tenantId
      }
    ]
    createMode:'default'
    networkAcls:{
      bypass:'AzureServices'
      defaultAction:'Deny'
      ipRules:[
        {
          value:publicIpAddress
        }
      ]
      virtualNetworkRules:[
      {
        id: gatewaySubnetId
      }
      {
        id: azureBastionSubnetId
      }
      {
        id: subnetId
      }
      ]
    }
    provisioningState:'Succeeded'
  }
}
