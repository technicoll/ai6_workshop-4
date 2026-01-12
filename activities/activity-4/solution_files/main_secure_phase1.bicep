// SECURE BASELINE - PHASE 1
// Security properties only (no parameters yet)
// This is the completed version from Activity 4

resource secureStorage 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: 'secure${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  
  sku: {
    name: 'Standard_LRS'
  }
  
  kind: 'StorageV2'

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
  name: 'raw-secure'
  properties: {
    // FIX #3 - Explicitly private container
    publicAccess: 'None'
  }
}

/*
✅ COMPLETED TEMPLATE - ACTIVITY 4
- Blocks public blob access at the account level
- Enforces TLS 1.2
- Creates a private container 'raw-secure'
- Uses modern StorageV2 type
*/
