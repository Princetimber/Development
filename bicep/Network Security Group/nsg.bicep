@description('network security group for the virtual network name suffix')
param networkSecurityGroupNameSuffix string = '-nsg'
param location string = resourceGroup().location
param destinationAddressPrefix string = 'virtualNetwork'
param sourceAddressPrefix string
param networkSecurityGroupName string = '${toLower(replace(resourceGroup().name, 'rg', ''))}${networkSecurityGroupNameSuffix}'
@description('network security group settings object')
param nsgSettings object = {
  name: networkSecurityGroupName
  location: location
  properties: {
    flushconnections: false
    securityRules: [
      {
        name: 'Allow_http(s)_inbound'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          priority: 100
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: destinationAddressPrefix
        }
      }
      {
        name: 'Allow_http_inbound'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          priority: 110
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: destinationAddressPrefix
        }
      }
      {
        name: 'Allow_ssh_inbound'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          priority: 120
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: destinationAddressPrefix
        }
      }
      {
        name: 'Allow_rdp_inbound'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          priority: 130
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3360-3400'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: destinationAddressPrefix
        }
      }
      {
        name: 'Allow_winrm_inbound'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          priority: 140
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '5980-5990'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: destinationAddressPrefix
        }
      }
      {
        name: 'Allow_dns_inbound'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          priority: 150
          protocol: 'udp'
          sourcePortRange: '*'
          destinationPortRange: '53'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: destinationAddressPrefix
        }
      }
      {
        name: 'Allow_ldap_inbound'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          priority: 160
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: destinationAddressPrefix
        }
      }
      {
        name: 'Allow_ldap_ssl_inbound'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          priority: 170
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '636'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: destinationAddressPrefix
        }
      }
      {
        name: 'Allow_kerberos_inbound'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          priority: 180
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '88'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: destinationAddressPrefix
        }
      }
      {
        name: 'Allow_kerberos_ssl_inbound'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          priority: 190
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '464'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: destinationAddressPrefix
        }
      }
      {
        name: 'Allow_kerberos_kdc_inbound'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          priority: 200
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '88'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: destinationAddressPrefix
        }
      }
      {
        name: 'Allow_ntp_inbound'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          priority: 210
          protocol: 'Udp'
          sourcePortRange: '*'
          destinationPortRange: '123'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: destinationAddressPrefix
        }
      }
      {
        name: 'allow_dns_tcp_inbound'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          priority: 220
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '53'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: destinationAddressPrefix
        }
      }
      {
        name: 'allow_smb_inbound'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          priority: 230
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '445'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: destinationAddressPrefix
        }
      }
    ]
  }

}
@description('allow https inbound rule settings object')
param allowhttpsInboundRuleSettings object = {
  name: '${networkSecurityGroupName}/Allow_http(s)_inbound'
  properties: {
    direction: 'Inbound'
    access: 'Allow'
    priority: 100
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: destinationAddressPrefix
  }
}
@description('allow http inbound rule settings object')
param allowhttpInboundRuleSettings object = {
  name: '${networkSecurityGroupName}/Allow_http_inbound'
  properties: {
    direction: 'Inbound'
    access: 'Allow'
    priority: 110
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '80'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: destinationAddressPrefix
  }
}
@description('allow ssh inbound rule settings object')
param allowsshInboundRuleSettings object = {
  name: '${networkSecurityGroupName}/Allow_ssh_inbound'
  properties: {
    direction: 'Inbound'
    access: 'Allow'
    priority: 120
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '22'
    sourceAddressPrefix: sourceAddressPrefix
    destinationAddressPrefix: destinationAddressPrefix
  }
}
@description('allow rdp inbound rule settings object')
param allowrdpInboundRuleSettings object = {
  name: '${networkSecurityGroupName}/Allow_rdp_inbound'
  properties: {
    direction: 'Inbound'
    access: 'Allow'
    priority: 130
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '3360-3400'
    sourceAddressPrefix: sourceAddressPrefix
    destinationAddressPrefix: destinationAddressPrefix
  }
}
@description('allow winrm inbound rule settings object')
param allowwinrmInboundRuleSettings object = {
  name: '${networkSecurityGroupName}/Allow_winrm_inbound'
  properties: {
    direction: 'Inbound'
    access: 'Allow'
    priority: 140
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '5980-5990'
    sourceAddressPrefix: sourceAddressPrefix
    destinationAddressPrefix: destinationAddressPrefix
  }
}
@description('allow dns inbound rule settings object')
param allowdnsInboundRuleSettings object = {
  name: '${networkSecurityGroupName}/Allow_dns_inbound'
  properties: {
    direction: 'Inbound'
    access: 'Allow'
    priority: 150
    protocol: 'udp'
    sourcePortRange: '*'
    destinationPortRange: '53'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: destinationAddressPrefix
  }
}
@description('allow ldap inbound rule settings object')
param allowldapInboundRuleSettings object = {
  name: '${networkSecurityGroupName}/Allow_ldap_inbound'
  properties: {
    direction: 'Inbound'
    access: 'Allow'
    priority: 160
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '389'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: destinationAddressPrefix
  }
}
param allowldapsslInboundRuleSettings object = {
  name: '${networkSecurityGroupName}/Allow_ldap_ssl_inbound'
  properties: {
    direction: 'Inbound'
    access: 'Allow'
    priority: 170
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '636'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: destinationAddressPrefix
  }
}
param allowkerberosInboundRuleSettings object = {
  name: '${networkSecurityGroupName}/Allow_kerberos_inbound'
  properties: {
    direction: 'Inbound'
    access: 'Allow'
    priority: 180
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '88'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: destinationAddressPrefix
  }
}
param allowkerberossslInboundRuleSettings object = {
  name: '${networkSecurityGroupName}/Allow_kerberos_ssl_inbound'
  properties: {
    direction: 'Inbound'
    access: 'Allow'
    priority: 190
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '464'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: destinationAddressPrefix
  }
}
param allowkerberoskdcInboundRuleSettings object = {
  name: '${networkSecurityGroupName}/Allow_kerberos_kdc_inbound'
  properties: {
    direction: 'Inbound'
    access: 'Allow'
    priority: 200
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '88'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: destinationAddressPrefix
  }
}
param allowntpInboundRuleSettings object = {
  name: '${networkSecurityGroupName}/Allow_ntp_inbound'
  properties: {
    direction: 'Inbound'
    access: 'Allow'
    priority: 210
    protocol: 'Udp'
    sourcePortRange: '*'
    destinationPortRange: '123'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: destinationAddressPrefix
  }
}
param allowdnstcpInboundRuleSettings object = {
  name: '${networkSecurityGroupName}/Allow_dns_tcp_inbound'
  properties: {
    direction: 'Inbound'
    access: 'Allow'
    priority: 220
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '53'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: destinationAddressPrefix
  }
}
param allowsmbInboundRuleSettings object = {
  name: '${networkSecurityGroupName}/Allow_smb_inbound'
  properties: {
    direction: 'Inbound'
    access: 'Allow'
    priority: 230
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '445'
    sourceAddressPrefix: sourceAddressPrefix
    destinationAddressPrefix: destinationAddressPrefix
  }
}
resource nsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {
  name: nsgSettings.name
  location: location
  properties: nsgSettings.properties
  tags: {
    displayName: 'Network Security Group'
  }
}
resource allowhttpsInboundtrafficRule 'Microsoft.Network/networkSecurityGroups/securityRules@2022-09-01' = {
  name: allowhttpsInboundRuleSettings.name
  dependsOn: [
    nsg
  ]
  properties: allowhttpsInboundRuleSettings.properties
}
resource allowhttpInboundtrafficRule 'Microsoft.Network/networkSecurityGroups/securityRules@2022-09-01' = {
  name: allowhttpInboundRuleSettings.name
  dependsOn: [
    nsg
  ]
  properties: allowhttpInboundRuleSettings.properties
}
resource allowsshInboundtrafficRule 'Microsoft.Network/networkSecurityGroups/securityRules@2022-09-01' = {
  name: allowsshInboundRuleSettings.name
  dependsOn: [
    nsg
  ]
  properties: allowsshInboundRuleSettings.properties
}
resource allowrdpInboundtrafficRule 'Microsoft.Network/networkSecurityGroups/securityRules@2022-09-01' = {
  name: allowrdpInboundRuleSettings.name
  dependsOn: [
    nsg
  ]
  properties: allowrdpInboundRuleSettings.properties
}
resource allowwinrmInboundtrafficRule 'Microsoft.Network/networkSecurityGroups/securityRules@2022-09-01' = {
  name: allowwinrmInboundRuleSettings.name
  dependsOn: [
    nsg
  ]
  properties: allowwinrmInboundRuleSettings.properties
}
resource allowdnsInboundtrafficRule 'Microsoft.Network/networkSecurityGroups/securityRules@2022-09-01' = {
  name: allowdnsInboundRuleSettings.name
  dependsOn: [
    nsg
  ]
  properties: allowdnsInboundRuleSettings.properties
}
resource allowldapInboundtrafficRule 'Microsoft.Network/networkSecurityGroups/securityRules@2022-09-01' = {
  name: allowldapInboundRuleSettings.name
  dependsOn: [
    nsg
  ]
  properties: allowldapInboundRuleSettings.properties
}
resource allowldapsslInboundtrafficRule 'Microsoft.Network/networkSecurityGroups/securityRules@2022-09-01' = {
  name: allowldapsslInboundRuleSettings.name
  dependsOn: [
    nsg
  ]
  properties: allowldapsslInboundRuleSettings.properties
}
resource allowkerberosInboundtrafficRule 'Microsoft.Network/networkSecurityGroups/securityRules@2022-09-01' = {
  name: allowkerberosInboundRuleSettings.name
  dependsOn: [
    nsg
  ]
  properties: allowkerberosInboundRuleSettings.properties
}
resource allowkerberossslInboundtrafficRule 'Microsoft.Network/networkSecurityGroups/securityRules@2022-09-01' = {
  name: allowkerberossslInboundRuleSettings.name
  dependsOn: [
    nsg
  ]
  properties: allowkerberossslInboundRuleSettings.properties
}
resource allowkerberoskdcInboundtrafficRule 'Microsoft.Network/networkSecurityGroups/securityRules@2022-09-01' = {
  name: allowkerberoskdcInboundRuleSettings.name
  dependsOn: [
    nsg
  ]
  properties: allowkerberoskdcInboundRuleSettings.properties
}
resource allowntpInboundtrafficRule 'Microsoft.Network/networkSecurityGroups/securityRules@2022-09-01' = {
  name: allowntpInboundRuleSettings.name
  dependsOn: [
    nsg
  ]
  properties: allowntpInboundRuleSettings.properties
}
resource allowdnstcpInboundtrafficRule 'Microsoft.Network/networkSecurityGroups/securityRules@2022-09-01' = {
  name: allowdnstcpInboundRuleSettings.name
  dependsOn: [
    nsg
  ]
  properties: allowdnstcpInboundRuleSettings.properties
}
resource allowsmbInboundtrafficRule 'Microsoft.Network/networkSecurityGroups/securityRules@2022-09-01' = {
  name: allowsmbInboundRuleSettings.name
  dependsOn: [
    nsg
  ]
  properties: allowsmbInboundRuleSettings.properties
}
output nsgName string = nsg.name
output nsgId string = nsg.id
