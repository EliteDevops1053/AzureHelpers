@description('The resource tags to add to object being created.')
param resourceTags object

@description('The name of the Key Vault resource you are creating.')
param keyVaultName string

@description('The location of the Key Vault resource you are creating.')
param keyVaultLocation string = resourceGroup().location

@description('The tenant id that should be used to authenticate requests to this key vault.')
param tenantId string

@description('This value determines whether access is allowed from all networks or only set virtual networks')
param networkAclsDefaultAction string

param DbName string

param ServerName string

resource keyVault 'Microsoft.KeyVault/vaults@2018-02-14' = {
  name: keyVaultName
  location: keyVaultLocation
  tags: resourceTags
  properties: {
    enableSoftDelete: true
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    tenantId: tenantId
    accessPolicies: []
    sku: {
      name: 'standard'
      family: 'A'
    }
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: networkAclsDefaultAction
    }
  }
}

resource DBNamedetails 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: DbName
  parent: keyVault
  properties: {
    contentType: 'string'
    value: 'string'
  }
}

resource Serverdetails 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: ServerName

  parent: keyVault
  properties: {
    contentType: 'string'
    value: 'string'
  }
}

output keyVault object = keyVault.properties
