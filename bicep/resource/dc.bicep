@description('virtual machine name(s)')
param name string
@description('specify virtualmachine sku')
@allowed([
  '2022-Datacenter-core'
  '2022-Datacenter'
  '2022-Datacenter-g2'
  '2022-Datacenter-core-g2'
])
param sku string = '2022-Datacenter-core-g2'
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
param licenseType string = 'Windows_Server'
param publisher string = 'MicrosoftWindowsServer'
param Offer string = 'WindowsServer'
param virtualMachineExtensionCustomScriptUri string
param location string = resourceGroup().location
@description('specify static IpAddress for virtualMachine')
param privateIpAddress string
param dnsServers array = [
  '172.16.2.4'
  '1.1.1.1'
  '8.8.8.8'
]
@description('specify autoshutdown status. acceptable values enable or disable')
@allowed([
  'enabled'
  'disabled'
])
param autoShutdownStatus string = 'enabled'
param autoShutdownTime string = '18:00'
param autoShutdownTimezone string = 'GMT Standard Time'
@description('enable or disable notification to adminuser before machine is autoshutdown')
@allowed([
  'enabled'
  'disabled'
])
param autoShutdownNotificationStatus string ='enabled'
param autoShutdownNotificationLocale string = 'en'
param autoShutdownNotificationEmail string = 'shutdown@fountview.co.uk'
param autoShutdownNotificationTimeInMinutes int = 30
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
resource stg 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storageAccountName
}
var stgaUri = stg.properties.primaryEndpoints.blob
resource ppgrp 'Microsoft.Compute/proximityPlacementGroups@2022-03-01' = {
  name:proximityPlacementGroupName
  location:location
  tags:{
    DisplayName:'ProximityPlacementGroup'
    CostCenter:'Engineering'
  }
  properties:{
    proximityPlacementGroupType:'Standard'
  }
}
resource availabilitySet 'Microsoft.Compute/availabilitySets@2022-03-01'={
  name: availabilitySetName
  location:location
  tags:{
    DisplayName:'AvailabilitySet'
    CostCenter:'Engineering'
  }
  properties:{
    platformFaultDomainCount:2
    platformUpdateDomainCount:5
    proximityPlacementGroup:{
      id:ppgrp.id
    }
  }
  sku:{
    name:'Aligned'
  }
}
resource nic 'Microsoft.Network/networkInterfaces@2022-01-01' = [for i in VirtualMachineCountRange: {
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
            id:'${vnet.id}/Subnets/subnet0'
          }
          privateIPAddressVersion:'IPv4'
          privateIPAllocationMethod:'Static'
          privateIPAddress:privateIpAddress
        }
      }
    ]
    dnsSettings:{
      dnsServers:dnsServers
    }
    nicType:'Standard'
  }
}]
resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-03-01' = [for i in VirtualMachineCountRange: {
  name:'${name}${i+1}'
  location:location
  tags:{
    DisplayName:'VirtualMachine'
    CostCenter:'Engineering'
  }
  properties:{
    availabilitySet:{
      id:availabilitySet.id
    }
    proximityPlacementGroup:{
      id:ppgrp.id
    }
    diagnosticsProfile:{
      bootDiagnostics:{
        enabled:true
        storageUri:stgaUri
      }
    }
    hardwareProfile:{
      vmSize:size
    }
    licenseType:licenseType
    networkProfile:{
      networkInterfaces:[
        {
          id:resourceId('Microsoft.network/NetworkInterfaces','${name}${i+1}${networkInterfaceSuffix}')
          properties:{
            deleteOption:'Delete'
             primary:true
          }
        }
      ]
    }
    osProfile:{
      adminUsername:userName
      adminPassword:password
      computerName:'${name}${i+1}'
      allowExtensionOperations:true
      windowsConfiguration:{
        provisionVMAgent:true
        enableAutomaticUpdates:true
        timeZone:'GMT Standard Time'
        winRM:{
          listeners:[
            {
              certificateUrl:certificateUri
              protocol:'Https'
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
      dataDisks:[
        {
          createOption: 'Empty'
          lun:0
          caching:'None'
          diskSizeGB:diskSize
          managedDisk:{
            storageAccountType:storageAccountType
          }
          name:'${name}${i+1}_data_disk'
          deleteOption:'Delete'
        }
      ]
      imageReference:{
        offer:Offer
        publisher:publisher
        sku:sku
        version:'latest'
      }
      osDisk:{
        createOption: 'FromImage'
        caching:'ReadWrite'
        deleteOption:'Delete'
        name:'${name}${i+1}_OSDisk'
        managedDisk:{
         storageAccountType:storageAccountType
        }
        osType:'Windows'
      }
    }
    scheduledEventsProfile:{
      terminateNotificationProfile:{
        enable:true
        notBeforeTimeout:'PT5M'
      }
    }
    securityProfile:{
      securityType:'TrustedLaunch'
      uefiSettings:{
        secureBootEnabled:true
        vTpmEnabled:true
      }
    }
  }
  identity:{
    type:'SystemAssigned'
  }
  zones:[
    '2'
  ]
}]
resource extensions 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = [for i in VirtualMachineCountRange: {
  name: '${name}${i+1}/config-app'
  location:location
  properties:{
    publisher:'Microsoft.Compute'
    type:'CustomScriptExtension'
    typeHandlerVersion:'1.10'
    autoUpgradeMinorVersion:true
    settings:{
      fileUris:[
        virtualMachineExtensionCustomScriptUri
      ]
      commanToExecute:'powershell.exe -ExecutionPolicy Bypass -file ./${last(split(virtualMachineExtensionCustomScriptUri,'/'))}'
    }
  }
  dependsOn:[
    virtualMachine
  ]
}]
resource shutdown_ComputeVM 'Microsoft.DevTestLab/schedules@2018-09-15' = [for i in VirtualMachineCountRange: {
  name:'shutdown-computevm-${name}${i+1}'
  location:location
  tags:{
    DisplayName:'Shutdown-ComputeVM'
    CostCenter:'Engineering'
  }
  properties:{
    status:autoShutdownStatus
    taskType:'ComputeVmShutdownTask'
    dailyRecurrence:{
      time:autoShutdownTime
    }
    timeZoneId:autoShutdownTimezone
    targetResourceId:resourceId('Microsoft.Compute/VirtualMachines','${name}${i+1}')
    notificationSettings:{
      status:autoShutdownNotificationStatus
      notificationLocale: autoShutdownNotificationLocale
      timeInMinutes:autoShutdownNotificationTimeInMinutes
      emailRecipient:autoShutdownNotificationEmail
    }
  }
  dependsOn:[
    virtualMachine
  ]

}]
