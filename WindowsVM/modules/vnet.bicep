// Creates a virtual network
@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('Name of the virtual network resource')
param virtualNetworkName string

@description('Group ID of the network security group')
param networkSecurityGroupId string

@description('Virtual network address prefix')
param vnetAddressPrefix string

@description('Training subnet address prefix')
param vnetSubnetPrefix string

// Create the virtual network
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: virtualNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    // Create the subnet/s
    subnets: [
      { 
        name: 'snet-01'
        properties: {
          addressPrefix: vnetSubnetPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
          networkSecurityGroup: {
            id: networkSecurityGroupId
          }
        }
      }
    ]
  }
}
    
// In case, the virtual network already exist
// resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
//   name: virtualNetworkName

output id string = virtualNetwork.id
output name string = virtualNetwork.name
