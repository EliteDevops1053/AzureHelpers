param location string
param storageAccountName string
param accountType string
param kind string
param accessTier string
param minimumTlsVersion string
param supportsHttpsTrafficOnly bool
param allowBlobPublicAccess bool
param allowSharedKeyAccess bool
param allowCrossTenantReplication bool
param defaultOAuthAuth bool
param networkAclsBypass string
param networkAclsDefaultAction string
param fileShareName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: accountType
  }
  kind: kind
  properties: {
    accessTier: accessTier
    minimumTlsVersion: minimumTlsVersion
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    allowCrossTenantReplication: allowCrossTenantReplication
    defaultToOAuthAuthentication: defaultOAuthAuth
    networkAcls: {
      defaultAction: networkAclsDefaultAction
      bypass: networkAclsBypass
      ipRules: []

    }
  }
}

resource filesharedetails 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-05-01' = {
  name: '${storageAccountName}/default/${fileShareName}'
}
