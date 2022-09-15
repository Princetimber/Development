@description('virtual machine name(s)')
param name string
@description('specify virtualmachine sku')
@allowed([
  '18_04-lts-gen2'
  '18.04-LTS'
  '19_04-gen2'
])
param sku string
@description('storage Account Type')
@allowed([
  'standard_LRS'
  'Premium_LRS'
])
param storageAccountType string = 'standard_LRS'
@description('virtualMachine size')
@allowed([
  'standard_DS1_v2'
  'standard_DS2_v2'
])
param size string = 'standard_DS1_v2'
@description('specify user Account Name')
param userName string
@description('specify secure machine Password')
@secure()
param password string
@description('specify virtualmachine disk size in gigabytes')
@minValue(60)
@maxValue(128)
param diskSize int = 128
@description('minimum number for machines to be created')
@minValue(1)
param virtualMachineCount int
param availabilitySetSuffix string = 'avset'
param proximityPlacementGroupSuffix string = 'ppg'
param vnetsuffix string = 'vnet'
param stgaSuffix string = 'stga'
param keyvaultSuffix string = 'kv'
param networkInterfaceSuffix string = 'vnic'
param dnsServers array = [
  '172.16.2.4'
  '172.16.2.5'
  '1.1.1.1'
  '8.8.8.8'
]
param publisher string = 'Canonical'
param Offer string = 'UbuntuServer'
param location string = resourceGroup().location
@description('specify static IpAddress for virtualMachine')
param privateIpAddress string
var VirtualMachineCountRange = range(0,virtualMachineCount)
var availabilitySetName = '${toLower(resourceGroup().name)}${availabilitySetSuffix}'
var proximityPlacementGroupName ='${toLower(resourceGroup().name)}${proximityPlacementGroupSuffix}'
var virtualNetworkName = '${toLower(resourceGroup().name)}${vnetsuffix}'
var storageAccountName = '${uniqueString(resourceGroup().id)}${stgaSuffix}'
var KeyVaultName = '${toLower(resourceGroup().name)}${keyvaultSuffix}'
resource vault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: KeyVaultName
}
var vaultId = vault.id
var vaultUri = vault.properties.vaultUri
var certificateUri = '${vaultUri}secrets/365cloudCert/'//enter correct key version
resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing= {
  name: virtualNetworkName
}
var vnetId = vnet.id
resource stg 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storageAccountName
}
var stgaUri = stg.properties.primaryEndpoints.blob
resource ppgrp 'Microsoft.Compute/proximityPlacementGroups@2022-03-01' existing = {
  name: proximityPlacementGroupName
}
var ppgrpId = ppgrp.id
resource availabilityset 'Microsoft.Compute/availabilitySets@2022-03-01'existing = {
  name: availabilitySetName
}
var availabilitySetId = availabilityset.id

resource networkInterface 'Microsoft.Network/networkInterfaces@2022-01-01' = [for i in VirtualMachineCountRange: {
  name:'${name}${i+1}${networkInterfaceSuffix}'
  location:location
  tags:{
    DisplayName:'NetworkInterface'
    CostCenter:'Engineering'
  }
  properties:{
    ipConfigurations:[
      {
        name:'IpConfiguration'
        properties:{
          primary:true
          subnet:{
            id:resourceId('${vnetId}/subnets/','subnet0')
          }
          privateIPAddressVersion:'IPv4'
          privateIPAllocationMethod:'Static'
          privateIPAddress:privateIpAddress
        }
      }
    ]
    nicType:'Standard'
    dnsSettings:{
      dnsServers:dnsServers
    }
  }
}]
resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-03-01'=[for i in VirtualMachineCountRange: {
  name:'${name}${i+1}'
  location:location
  tags:{
    DisplayName:'VirtualMachine'
    CostCenter:'Engineering'
  }
  properties:{
    availabilitySet:{
      id:availabilitySetId
    }
    proximityPlacementGroup:{
      id:ppgrpId
    }
    diagnosticsProfile:{
      bootDiagnostics:{
        enabled:true
        storageUri:stgaUri
      }
    }
    networkProfile:{
      networkInterfaces:[
        {
          id:resourceId('Microsoft.network/NetworkInterfaces','${name}${i+1}${networkInterfaceSuffix}')
        }
      ]
    }
    hardwareProfile:{
      vmSize:size
    }
    osProfile:{
      adminUsername:userName
      adminPassword:password
      computerName:'${name}${i+1}'
      allowExtensionOperations:true
      linuxConfiguration:{
        disablePasswordAuthentication:true
        provisionVMAgent:true
        ssh:{
          publicKeys:[
            {
              path:'/home/${userName}/.ssh/authorized_keys'
              keyData:password
            }
          ]
        }
      }
      secrets:[
        {
          sourceVault:{
            id:vaultId
          }
          vaultCertificates:[
            {
              certificateStore:'My'
              certificateUrl:certificateUri
            }
          ]
        }
      ]
    }
    storageProfile:{
      osDisk:{
        createOption: 'FromImage'
        name:'${name}${i+1}_OS_disk'
        caching:'ReadWrite'
        deleteOption:'Delete'
        osType:'Linux'
        diskSizeGB:diskSize
        managedDisk:{
          storageAccountType:storageAccountType
        }
      }
      imageReference:{
        offer:Offer
        publisher:publisher
        sku:sku
        version:'latest'
      }
    }
    scheduledEventsProfile:{
      terminateNotificationProfile:{
        enable:true
        notBeforeTimeout:'PT5M'
      }
    }
  }
}]
output adminUser string = userName
output hostname string = privateIpAddress
output sshcommand string = 'ssh ${userName}@${privateIpAddress}'
