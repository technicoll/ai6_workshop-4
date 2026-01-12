// SECURE BASELINE - PHASE 2
// Security properties + parameters for environment-specific values
//
// Parameters for environment-specific values
@allowed(['dev', 'test', 'live', 'prod'])
param env string = 'dev'
param location string = resourceGroup().location
param owner string = 'ml-engineering-team'

// Define the storage account resource
resource secureStorage 'Microsoft.Storage/storageAccounts@2021-09-01' = {

  // Environment-aware unique name (max 24 chars)
  // safe (4) + env (max 4) + uniqueString (13) = 21 chars max
  name: 'safe${env}${uniqueString(resourceGroup().id)}'

  // Use location parameter
  location: location

  sku: {
    name: 'Standard_LRS'
  }

  kind: 'StorageV2'

  tags: {
    environment: env
    owner: owner
    costCentre: 'ml-eng'
    managedBy: 'IaC'
  }

  properties: {
    // FIX #1 - Block public access at account level
    allowBlobPublicAccess: false

    // FIX #2 - Enforce modern TLS
    minimumTlsVersion: 'TLS1_2'
  }
}

// Define blob service resource
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  parent: secureStorage
  name: 'default'
}

// Define secure container resource
resource rawSecure 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  parent: blobService
  name: 'raw-${env}'
  properties: {
    // FIX #3 - Explicitly private container
    publicAccess: 'None'
  }
}

// Outputs
output storageAccountName string = secureStorage.name
output containerName string = rawSecure.name
output environment string = env

/*
✅ WHEN COMPLETE, YOUR TEMPLATE SHOULD:
- Create a storage account named 'secure<random-string>'
- Block public blob access at the account level
- Enforce TLS 1.2
- Create a container 'raw-secure' with no public access

⚠️ DO NOT deploy yet - we'll add parameters in Activity 6 first!
*/
