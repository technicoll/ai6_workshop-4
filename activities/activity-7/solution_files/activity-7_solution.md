# Activity 7: Staging Gate (what-if) - SOLUTION

---

## ✅ Expected what-if Output

```
Resource and property changes are indicated with this symbol:
  + Create
  ~ Modify
  - Delete
  * Ignore

The deployment will update the following scope:

Scope: /subscriptions/xxxxx/resourceGroups/1-e58d5f37-playground-sandbox

  + Microsoft.Storage/storageAccounts/safedevg4k7m9x2pq3s [2021-09-01]

      apiVersion:                "2021-09-01"
      kind:                      "StorageV2"
      location:                  "eastus"
      name:                      "safedevg4k7m9x2pq3s"
      properties.accessTier:     "Hot"
      properties.allowBlobPublicAccess:     false
      properties.minimumTlsVersion:         "TLS1_2"
      properties.supportsHttpsTrafficOnly:  true
      sku.name:                  "Standard_LRS"
      tags.costCentre:           "ml-eng"
      tags.environment:          "dev"
      tags.managedBy:            "IaC"
      tags.owner:                "ml-engineering-team"
      type:                      "Microsoft.Storage/storageAccounts"

  + Microsoft.Storage/storageAccounts/safedevg4k7m9x2pq3s/blobServices/default [2021-09-01]

      apiVersion:                "2021-09-01"
      name:                      "default"
      type:                      "Microsoft.Storage/storageAccounts/blobServices"

  + Microsoft.Storage/storageAccounts/safedevg4k7m9x2pq3s/blobServices/default/containers/raw-dev [2021-09-01]

      apiVersion:                "2021-09-01"
      name:                      "raw-dev"
      properties.publicAccess:   "None"
      type:                      "Microsoft.Storage/storageAccounts/blobServices/containers"

Resource changes: 3 to create.
```

---

## 📖 Reading the Output

**Symbols:**
- `+` = Will create
- `~` = Will modify
- `-` = Will delete ⚠️
- `*` = Will ignore (no change)

**Key sections:**
- `apiVersion` - API version used
- `properties.*` - Resource configuration
- `tags.*` - Governance metadata

---

## ✅ Validation Checklist

- [ ] **3 resources to create** (storage account, blob service, container)
- [ ] **0 resources to delete** (no accidental deletions!)
- [ ] `allowBlobPublicAccess: false` ✅
- [ ] `minimumTlsVersion: "TLS1_2"` ✅
- [ ] `publicAccess: "None"` ✅
- [ ] Tags include: environment, owner, costCentre, managedBy

If all checkboxes pass: **SAFE TO DEPLOY**!

---

## ✅ Checkpoint: Understanding what-if

Answer these questions:

**Q1: What does `+ Create` mean?**
- ✅ Azure will create a new resource

**Q2: What does `- Delete` mean?**
- ✅ Azure will delete an existing resource (⚠️ BE CAREFUL!)

**Q3: What does `~ Modify` mean?**
- ✅ Azure will change properties of an existing resource

**Q4: When should you run what-if?**
- ✅ ALWAYS before deploying to test or live!

---


## 🔗 Next Activity

Move to [Activity 8: Secure Deployment](../activity-8/activity-8_start.md)
