param location string = resourceGroup().location
param tenantId string = subscription().tenantId
param objectId string //AAD User ObjectId
param suffix string = 'kv'
param vnetsuffix string = 'vnet'
param publicIpAddress string //Enter public IPAddress
var name = '${toLower(replace(resourceGroup().name,'rg',''))}${suffix}'
var vnetName = '${toLower(replace(resourceGroup().name,'rg',''))}${vnetsuffix}'
resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnetName
}
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
        id:'${vnet.id}/subnets/gatewaySubnet'
      }
      {
        id:'${vnet.id}/subnets/Subnet0'
      }
      ]
    }
    provisioningState:'Succeeded'
  }
  tags:{
    DisplayName:'KeyVault'
    CostCenter:'Engineering'
  }
}
output name string = keyvaults.name
