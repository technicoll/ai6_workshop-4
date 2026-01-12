# Activity 6: Parameterisation - SOLUTION

---

## ✅ Complete Parameterized Template

This is the complete solution (also available in `templates/main_secure_complete.bicep`):

```bicep
// SECURE BASELINE - COMPLETE
// With parameterisation for environment promotion

// Parameters for environment-specific values
@allowed(['dev', 'test', 'live', 'prod'])
param env string = 'dev'
param location string = resourceGroup().location
param owner string = 'ml-engineering-team'

resource secureStorage 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  // Environment-aware unique name (max 24 chars)
  name: 'safe${env}${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'

  // Governance tags
  tags: {
    environment: env
    owner: owner
    costCentre: 'ml-eng'
    managedBy: 'IaC'
  }

  properties: {
    // ✅ FIX #1: Block public access at account level
    // Security invariant: NEVER parameterise this
    allowBlobPublicAccess: false

    // ✅ FIX #2: Enforce modern TLS
    // Security invariant: NEVER parameterise this
    minimumTlsVersion: 'TLS1_2'
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  parent: secureStorage
  name: 'default'
}

resource rawSecure 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  parent: blobService
  // Environment-aware container name
  name: 'raw-${env}'
  properties: {
    // ✅ FIX #3: Explicitly private container
    // Security invariant: NEVER parameterise this
    publicAccess: 'None'
  }
}

// Output useful information for verification
output storageAccountName string = secureStorage.name
output containerName string = rawSecure.name
output location string = secureStorage.location
output environment string = env
```

---

## 📊 What Changed

| Aspect | Phase 1 (Hard-coded) | Phase 2 (Parameterized) |
|--------|---------------------|------------------------|
| **Storage name** | `secure...` | `safe${env}...` |
| **Container name** | `raw-secure` | `raw-${env}` |
| **Tags** | None | env, owner, costCentre, managedBy |
| **Outputs** | None | storageAccountName, containerName, env |
| **Reusability** | Single environment | dev/test/live |

---

## 🔐 Security Invariants

These properties are **LOCKED** (not parameterized):
- `allowBlobPublicAccess: false`
- `minimumTlsVersion: 'TLS1_2'`
- `publicAccess: 'None'`

**Why?** Security properties should never vary by environment. Secure is secure everywhere!

---

## 🔗 Next Activity

Move to [Activity 7: Staging Gate (what-if)](../activity-7/activity-7_start.md)
