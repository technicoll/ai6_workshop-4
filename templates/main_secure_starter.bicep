// SECURE BASELINE - PHASE 1
// Security properties only (no parameters yet)
//
// Instructions: Replace each TODO with the correct code.
// Hints are provided in comments.

// TODO #1: Define the storage account resource
// HINT: Use resource type 'Microsoft.Storage/storageAccounts@2021-09-01'
resource secureStorage 'Microsoft.Storage/storageAccounts@2021-09-01' = {

  // TODO #2: Add a unique name
  // HINT: Use 'secure${uniqueString(resourceGroup().id)}'
  name: 'secure${uniqueString(resourceGroup().id)}'

  // TODO #3: Set location to the resource group's location
  // HINT: resourceGroup().location
  location: resourceGroup().location

  // TODO #4: Set SKU to Standard_LRS
  sku: {
    name: 'Standard_LRS'
  }

  // TODO #5: Set kind to StorageV2 (modern storage type)
  kind: 'StorageV2'

  properties: {
    // TODO #6: FIX #1 - Block public access at account level
    // HINT: Set allowBlobPublicAccess to false
    // allowBlobPublicAccess: false

    // TODO #7: FIX #2 - Enforce modern TLS
    // HINT: Set minimumTlsVersion to 'TLS1_2'
    // minimumTlsVersion: 'TLS1_2'
  }
}

// TODO #8: Define blob service resource
// HINT: Use resource type 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01'
// HINT: Set parent: secureStorage and name: 'default'
/*
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  parent: secureStorage
  name: 'default'
}
*/

// TODO #9: Define secure container resource
// HINT: Use resource type 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01'
// HINT: parent: blobService, name: 'raw-secure', publicAccess: 'None'
/*
resource rawSecure 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  parent: blobService
  name: 'raw-secure'
  properties: {
    // TODO #10: FIX #3 - Explicitly private container
    // HINT: Set publicAccess to 'None'
    publicAccess: 'None'
  }
}
*/

/*
✅ WHEN COMPLETE, YOUR TEMPLATE SHOULD:
- Create a storage account named 'secure<random-string>'
- Block public blob access at the account level
- Enforce TLS 1.2
- Create a container 'raw-secure' with no public access

⚠️ DO NOT deploy yet - we'll add parameters in Activity 6 first!
*/
