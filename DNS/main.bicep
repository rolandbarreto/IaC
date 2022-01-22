param rg_dnszone_name string = 'rg-dnszone-eastus'
param dnsZoneName string = 'dominio.com'

targetScope = 'subscription'

resource rgdnsZone 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rg_dnszone_name
  location: 'eastus'
}

module dnszone './dnszone.bicep' = {
  name: dnsZoneName
  scope: rgdnsZone
  params: {
    dnsZoneName: dnsZoneName
  }
}
