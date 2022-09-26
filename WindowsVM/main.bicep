// Parameters
@minLength(2)
@maxLength(10)
@description('Prefix for all resource names.')
param prefix string

@description('Azure region used for the deployment of all resources.')
param location string

@description('Virtual network resource group')
param otherResourceGroup string

@description('Virtual network address prefix')
param vnetAddressPrefix string

@description('Subnet address prefix')
param vnetSubnetPrefix string

@description('Allocation method for the Public IP used to access the Virtual Machine.')
param publicIPAllocationMethod string

@description('SKU for the Public IP used to access the Virtual Machine.')
param publicIpSku string

@description('Allocation method for the Private IP used to access the Virtual Machine')
param privateIPAllocationMethod string

@description('Virtual machine username')
param vm_username string

@secure()
@minLength(8)
@description('Virtual machine password')
param vm_password string

@description('VM size for the default compute cluster')
param vmsize string

@description('Storage account type')
param storageAccountType string

@description('Set of tags to apply to all resources.')
param tags object

// Variables
var name = toLower('${prefix}')

// Create a unique suffix for all the resources with the deployment
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 4)

// ==================  Modules  ======================

// Network security group
module nsg  'modules/nsg.bicep' = { 
  name: 'nsg-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    tags: tags 
    nsgName: 'nsg-${name}-${uniqueSuffix}'
  }
}

// Virtual Network
module vnet  'modules/vnet.bicep' = { 
  name: 'vnet-${name}-${uniqueSuffix}-deployment'
  scope: resourceGroup(otherResourceGroup)
  params: {
    location: location
    virtualNetworkName: 'vnet-${name}-${uniqueSuffix}'
    networkSecurityGroupId: nsg.outputs.networkSecurityGroup
    vnetAddressPrefix: vnetAddressPrefix
    vnetSubnetPrefix: vnetSubnetPrefix
    tags: tags
  }
}

// Virtual Machine
module VM  'modules/vm.bicep' = {
  name: 'vm-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    virtualMachineName: 'vm-${name}-${uniqueSuffix}'
    subnetId: '${vnet.outputs.id}/subnets/snet-01'
    adminUsername: vm_username
    adminPassword: vm_password
    networkSecurityGroupId: nsg.outputs.networkSecurityGroup
    vmSizeParameter: vmsize
    publicIPAllocationMethod: publicIPAllocationMethod
    publicIpSku: publicIpSku
    privateIPAllocationMethod: privateIPAllocationMethod
    storageAccountType: storageAccountType
    tags: tags
  }
}
