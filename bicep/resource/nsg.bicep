@description('nsg name suffix')
param suffix string
param sourceAddressPrefixes array
param destinationAddressPrefix string
param location string = resourceGroup().location

var name = '${toLower(replace(resourceGroup().name, 'rg', ''))}${suffix}'
var allowhttpsInboundTraffic = '${name}/Allow_https_Inbound_Traffic'
var allowhttpInboundTraffic = '${name}/Allow_http_inbound_Traffic'
var allowRdpInboundTraffic = '${name}/Allow_Rdp_Inbound_Traffic'
var allowSSHInboundTraffic = '${name}/Allow_ssh_Inbound_Traffic'
var allowWinRMInboundTraffic = '${name}/Allow_WinRM_Inbound_Traffic'
var allowDNSInboundTraffic = '${name}/Allow_DNS_Inbound_Traffic'
var allowNTPInboundUDPTraffic = '${name}/UDP_NTP_Inbound'

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: name
  location: location
  tags: {
    DisplayName: 'Network Security Group'
    CostCenter: 'Engineering'
  }
  properties: {
    flushConnection: false
    securityRules: [
      {
        name: 'Allow_https_inbound_traffic'
        properties: {
          direction: 'Inbound'
          priority: 201
          protocol: 'Tcp'
          access: 'Allow'
          description: 'Allow_https_inbound_traffic'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: destinationAddressPrefix
          destinationPortRange: '443'
        }
      }
      {
        name: 'Allow_http_inbound_traffic'
        properties: {
          description: 'Allow_http_inbound_traffic'
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          priority: 202
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: destinationAddressPrefix
          destinationPortRange: '80'

        }
      }
      {
        name: 'Allow_Rdp_inbound_traffic'
        properties: {
          description: 'Allow_Rdp_inbound_traffic'
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          priority: 203
          sourceAddressPrefixes: sourceAddressPrefixes
          sourcePortRange: '*'
          destinationAddressPrefix: destinationAddressPrefix
          destinationPortRange: '3360-3400'
        }
      }
      {
        name: 'Allow_SSH_inbound_traffic'
        properties: {
          description: 'Allow_SSH_Inbound_Traffic'
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          priority: 204
          sourceAddressPrefixes: sourceAddressPrefixes
          sourcePortRange: '*'
          destinationAddressPrefix: destinationAddressPrefix
          destinationPortRange: '22'
        }
      }
      {
        name: 'Allow_WinRM_Inbound_traffic'
        properties: {
          description: 'Allow_WinRM_inbound_Traffic'
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          priority: 205
          sourceAddressPrefixes: sourceAddressPrefixes
          sourcePortRange: '*'
          destinationAddressPrefix: destinationAddressPrefix
          destinationPortRange: '5980-5990'
        }
      }
      {
        name: 'Allow_DNS_inbound_traffic'
        properties: {
          description: 'Allow_DNS_traffic'
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          priority: 206
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: destinationAddressPrefix
          destinationPortRange: '53'
        }
      }
      {
        name: 'UDP_NTP_Inbound'
        properties: {
          description: 'Allow UDP NTP inbound traffic'
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Udp'
          priority: 207
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: destinationAddressPrefix
          destinationPortRange: '123'
        }
      }
    ]
  }
}
resource allowhttpsInboundTrafficRule 'Microsoft.Network/networkSecurityGroups/securityRules@2022-01-01' = {
  name: allowhttpsInboundTraffic
  dependsOn: [
    nsg
  ]
  properties: {
    direction: 'Inbound'
    protocol: 'Tcp'
    access: 'Allow'
    description: 'Allow_https_inbound_traffic'
    priority: 201
    sourceAddressPrefix: '*'
    sourcePortRange: '*'
    destinationAddressPrefix: destinationAddressPrefix
    destinationPortRange: '443'
  }
}
resource allowhttpInboundTrafficRule 'Microsoft.Network/networkSecurityGroups/securityRules@2022-01-01' = {
  name: allowhttpInboundTraffic
  dependsOn: [
    nsg
  ]
  properties: {
    description: 'Allow_http_inbound_traffic'
    access: 'Allow'
    direction: 'Inbound'
    protocol: 'Tcp'
    priority: 202
    sourceAddressPrefix: '*'
    sourcePortRange: '*'
    destinationAddressPrefix: destinationAddressPrefix
    destinationPortRange: '80'

  }
}
resource allowRdpInboundTrafficRule 'Microsoft.Network/networkSecurityGroups/securityRules@2022-01-01' = {
  name: allowRdpInboundTraffic
  dependsOn: [
    nsg
  ]
  properties: {
    description: 'Allow_Rdp_inbound_traffic'
    access: 'Allow'
    direction: 'Inbound'
    protocol: 'Tcp'
    priority: 203
    sourceAddressPrefixes: sourceAddressPrefixes
    sourcePortRange: '*'
    destinationAddressPrefix: destinationAddressPrefix
    destinationPortRange: '3360-3400'
  }
}
resource allowSSHInboundTrafficRule 'Microsoft.Network/networkSecurityGroups/securityRules@2022-01-01' = {
  name: allowSSHInboundTraffic
  dependsOn: [
    nsg
  ]
  properties: {
    description: 'Allow_SSH_Inbound_traffic'
    access: 'Allow'
    direction: 'Inbound'
    protocol: 'Tcp'
    priority: 204
    sourceAddressPrefixes: sourceAddressPrefixes
    sourcePortRange: '*'
    destinationAddressPrefix: destinationAddressPrefix
    destinationPortRange: '22'
  }
}
resource allowWinRMInboundTrafficRule 'Microsoft.Network/networkSecurityGroups/securityRules@2022-01-01' = {
  name: allowWinRMInboundTraffic
  dependsOn: [
    nsg
  ]
  properties: {
    description: 'Allow_WinRM_inbound_traffic'
    access: 'Allow'
    direction: 'Inbound'
    protocol: 'Tcp'
    priority: 205
    sourceAddressPrefixes: sourceAddressPrefixes
    sourcePortRange: '*'
    destinationAddressPrefix: destinationAddressPrefix
    destinationPortRange: '5980-5990'
  }
}
resource allowDNSInboundTrafficRule 'Microsoft.Network/networkSecurityGroups/securityRules@2022-01-01' = {
  name: allowDNSInboundTraffic
  dependsOn: [
    nsg
  ]
  properties: {
    description: 'Allow_DNS_Inbound_traffic'
    access: 'Allow'
    direction: 'Inbound'
    protocol: 'Tcp'
    priority: 206
    sourceAddressPrefix: '*'
    sourcePortRange: '*'
    destinationAddressPrefix: destinationAddressPrefix
    destinationPortRange: '53'
  }
}
resource allowNTPInboundTrafficRule 'Microsoft.Network/networkSecurityGroups/securityRules@2022-05-01' = {
  name: allowNTPInboundUDPTraffic
  dependsOn: [
    nsg
  ]
  properties: {
    description: 'Allow UDP NTP inbound traffic'
    access: 'Allow'
    direction: 'Inbound'
    protocol: 'Udp'
    sourceAddressPrefix: '*'
    sourcePortRange: '*'
    destinationAddressPrefix: destinationAddressPrefix
    destinationPortRange: '123'
    priority: 207
  }
}
output nsgname string = nsg.name
output nsgId string = nsg.id
