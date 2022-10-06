@description('virtual machine name(s)')
param name string
@description('specify virtualmachine sku')
@allowed([
  '18_04-lts-gen2'
  '18.04-LTS'
  '19_04-gen2'
  '22_04-lts-gen2'
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
  'standard_D2s_v3'
])
param VmSize string
@description('specify user Account Name')
param adminUsername string
@description('specify secure machine Password')
@secure()
param adminPassword string
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
param networkInterfaceSuffix string = 'vnic'
param dnsServers array = [
  '172.16.2.4'
  '1.1.1.1'
  '8.8.8.8'
]
param publisher string = 'Canonical'
@allowed([
  'UbuntuServer'
  '0001-com-ubuntu-server-jammy'
])
param Offer string
param location string = resourceGroup().location
@allowed([
  'enabled'
  'disabled'
])
param autoShutdownStatus string = 'enabled'
param autoShutdownTime string = '18:00'
param autoShutdownTimezone string = 'GMT Standard Time'
@allowed([
  'enabled'
  'disabled'
])
param autoShutdownNotificationStatus string = 'enabled'
param autoShutdownNotificationLocale string = 'en'
param autoShutdownNotificationEmail string = 'shutdown@fountview.co.uk'
param autoShutdownNotificationTimeInMinutes int = 30
@description('specify static IpAddress for virtualMachine')
param privateIpAddress string
var VirtualMachineCountRange = range(0, virtualMachineCount)
var availabilitySetName = '${toLower(replace(resourceGroup().name, 'rg', ''))}${availabilitySetSuffix}'
var proximityPlacementGroupName = '${toLower(replace(resourceGroup().name, 'rg', ''))}${proximityPlacementGroupSuffix}'
var virtualNetworkName = '${toLower(replace(resourceGroup().name, 'rg', ''))}${vnetsuffix}'
var storageAccountName = '${uniqueString(resourceGroup().id)}${stgaSuffix}'
resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: virtualNetworkName
}
resource stg 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storageAccountName
}
var storageUri = stg.properties.primaryEndpoints.blob
resource ppgrp 'Microsoft.Compute/proximityPlacementGroups@2022-03-01' existing = {
  name: proximityPlacementGroupName
}
var ppgrpId = ppgrp.id
resource availabilityset 'Microsoft.Compute/availabilitySets@2022-03-01' existing = {
  name: availabilitySetName
}
var availabilitySetId = availabilityset.id

resource networkInterface 'Microsoft.Network/networkInterfaces@2022-01-01' = [for i in VirtualMachineCountRange: {
  name: '${name}${i + 1}${networkInterfaceSuffix}'
  location: location
  tags: {
    DisplayName: 'NetworkInterface'
    CostCenter: 'Engineering'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'IpConfiguration'
        properties: {
          primary: true
          subnet: {
            id: '${vnet.id}/subnets/subnet0'
          }
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: 'Static'
          privateIPAddress: privateIpAddress
        }
      }
    ]
    nicType: 'Standard'
    dnsSettings: {
      dnsServers: dnsServers
    }
  }
}]
resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-03-01' = [for i in VirtualMachineCountRange: {
  name: '${name}${i + 1}'
  location: location
  tags: {
    DisplayName: 'VirtualMachine'
    CostCenter: 'Engineering'
  }
  properties: {
    availabilitySet: {
      id: availabilitySetId
    }
    proximityPlacementGroup: {
      id: ppgrpId
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: storageUri
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.network/NetworkInterfaces', '${name}${i + 1}${networkInterfaceSuffix}')
          properties: {
            deleteOption: 'Delete'
            primary: true
          }
        }
      ]
    }
    hardwareProfile: {
      vmSize: VmSize
    }
    osProfile: {
      adminUsername: adminUsername
      adminPassword: adminPassword
      computerName: '${name}${i + 1}'
      allowExtensionOperations: true
      linuxConfiguration: {
        disablePasswordAuthentication: true
        provisionVMAgent: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: adminPassword
            }
          ]
        }
        patchSettings: {
          assessmentMode: 'ImageDefault'
          patchMode: 'ImageDefault'
        }
      }
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        name: '${name}${i + 1}_OS_disk'
        caching: 'ReadWrite'
        deleteOption: 'Delete'
        osType: 'Linux'
        diskSizeGB: diskSize
        managedDisk: {
          storageAccountType: storageAccountType
        }
      }
      imageReference: {
        offer: Offer
        publisher: publisher
        sku: sku
        version: 'latest'
      }
    }
    scheduledEventsProfile: {
      terminateNotificationProfile: {
        enable: true
        notBeforeTimeout: 'PT5M'
      }
    }
    securityProfile: {
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}]
resource shutdown_ComputeVM 'Microsoft.DevTestLab/schedules@2018-09-15' = [for i in VirtualMachineCountRange: {
  name: 'shutdown-computevm-${name}${i + 1}'
  location: location
  tags: {
    DisplayName: 'Shutdown-ComputeVM'
    CostCenter: 'Engineering'
  }
  properties: {
    status: autoShutdownStatus
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: autoShutdownTime
    }
    timeZoneId: autoShutdownTimezone
    targetResourceId: resourceId('Microsoft.Compute/VirtualMachines', '${name}${i + 1}')
    notificationSettings: {
      status: autoShutdownNotificationStatus
      notificationLocale: autoShutdownNotificationLocale
      timeInMinutes: autoShutdownNotificationTimeInMinutes
      emailRecipient: autoShutdownNotificationEmail
    }
  }
  dependsOn: [
    virtualMachine
  ]
}]
output adminUser string = adminUsername
output hostname string = privateIpAddress
output sshcommand string = 'ssh ${adminUsername}@${privateIpAddress}'
