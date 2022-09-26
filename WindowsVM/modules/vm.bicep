// Creates a Data Science Virtual Machine jumpbox.
@description('Azure region of the deployment')
param location string

@description('Resource ID of the subnet')
param subnetId string

@description('Network Security Group Resource ID')
param networkSecurityGroupId string

@description('Virtual machine name')
param virtualMachineName string

@description('Virtual machine size')
param vmSizeParameter string

@description('Virtual machine admin username')
param adminUsername string

@description('Tags to add to the resources')
param tags object

@description('Allocation method for the Public IP used to access the Virtual Machine.')
param publicIPAllocationMethod string

@description('SKU for the Public IP used to access the Virtual Machine.')
param publicIpSku string

@description('Allocation method for the Private IP used to access the Virtual Machine')
param privateIPAllocationMethod string

@description('Storage account type')
param storageAccountType string

@secure()
@minLength(8)
@description('Virtual machine admin password')
param adminPassword string

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: '${virtualMachineName}-nic'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: privateIPAllocationMethod
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: networkSecurityGroupId
    }
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${virtualMachineName}-pip'
  location: location
  tags: tags
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: virtualMachineName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSizeParameter
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: storageAccountType
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
    osProfile: {
      computerName: virtualMachineName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        patchSettings: {
          enableHotpatching: false
          patchMode: 'AutomaticByOS'
        }
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}
