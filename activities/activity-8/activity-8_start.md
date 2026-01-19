# Activity 8: Fix-Forward Deployment

**Primary KSB:** S16 (transition to live operation)

---

## 🎯 Learning Objective

Deploy the secure infrastructure template and verify all security properties are correctly applied

---

## 📖 Fix-Forward Pattern

Before we deploy, let's understand the **fix-forward pattern** - the safest way to replace insecure infrastructure.

📊 **See the pattern:** [Fix-Forward vs Patch-In-Place](../../diagrams/ascii_diagrams.md#7-fix-forward-pattern-for-activity-8)

**Key principle:** Build new secure resources, verify they work, THEN remove old insecure ones.

"New bridge built before old bridge closed"

---

## 📝 Task 1: Deploy Secure Template (15 minutes)

### Step 1: Final Pre-Flight Check

⌨️ **Verify your template:**

```bash
code main_secure.bicep
```

Confirm these are present:
- `allowBlobPublicAccess: false`
- `minimumTlsVersion: 'TLS1_2'`
- `publicAccess: 'None'`

---

### Step 2: Deploy to Dev Environment

⌨️ **Run:**

```bash
az deployment group create \
  --resource-group $rg \
  --template-file main_secure.bicep \
  --parameters env=dev \
  --name secure-deployment
```

⏱️ **This takes 1-2 minutes**

---

### Step 3: Verify Success

✅ **Checkpoint:** You should see `"provisioningState": "Succeeded"`

Also note the **outputs** section:

```json
"outputs": {
  "storageAccountName": {
    "type": "String",
    "value": "safedevg4k7m9x2pq3s"
  },
  "containerName": {
    "type": "String",
    "value": "raw-dev"
  },
  "environment": {
    "type": "String",
    "value": "dev"
  }
}
```

---

## 📝 Task 2: Verify Security Properties

Now let's confirm the secure properties are actually applied.

### Step 1: List All Storage Accounts

⌨️ **Run:**

```bash
az storage account list -g $rg -o table
```

✅ **Checkpoint:** You should see two storage accounts if using Codespaces, and three if using Cloud Shell:
- `legacy...` (insecure - from Activity 2)
- `safedev...` (secure - just deployed!)
- `cloudaccount` (or whatever you called this storage account when setting up Cloud Shell)

---

### Step 2: Compare Security Properties

⌨️ **Check the NEW secure account:**

```bash
az storage account show \
  --name $(az storage account list -g $rg --query "[?starts_with(name, 'safe')].name" -o tsv) \
  --resource-group $rg \
  --query "{Name:name, TLS:minimumTlsVersion, PublicAccess:allowBlobPublicAccess, Kind:kind}" \
  --output table
```

✅ **Expected output:**
```
Name                    TLS     PublicAccess    Kind
----------------------  ------  --------------  ----------
safedevg4k7m9x2pq3s     TLS1_2  False           StorageV2
```

All secure! ✅

---

### Step 3: Check Container Properties

⌨️ **Run:**

```bash
SECURE_STORAGE=$(az storage account list -g $rg --query "[?starts_with(name, 'safe')].name" -o tsv)
az storage container show \
  --account-name $SECURE_STORAGE \
  --name raw-dev \
  --auth-mode login \
  --query "{Name:name, PublicAccess:properties.publicAccess}" \
  --output table
```

✅ **Expected output:**
```
Name
-------
raw-dev
```
The `PublicAccess` column is absent because the value is null—meaning the container is private. ✅

---

## 📝 Task 3: Compare Legacy vs Secure (10 minutes)

Let's see the difference side-by-side.

⌨️ **Option 1 - Create comparison script:**

```bash
cat > compare_storage.sh << 'EOF'
#!/bin/bash
echo "=== LEGACY STORAGE (INSECURE) ==="
LEGACY_NAME=$(az storage account list -g $rg --query "[?starts_with(name, 'legacy')].name" -o tsv)
az storage account show \
  --name "$LEGACY_NAME" \
  --resource-group $rg \
  --query "{TLS:minimumTlsVersion, PublicAccess:allowBlobPublicAccess}" \
  --output table

echo ""
echo "=== SECURE STORAGE (FIXED) ==="
SECURE_NAME=$(az storage account list -g $rg --query "[?starts_with(name, 'safe')].name" -o tsv)
az storage account show \
  --name "$SECURE_NAME" \
  --resource-group $rg \
  --query "{TLS:minimumTlsVersion, PublicAccess:allowBlobPublicAccess}" \
  --output table
EOF

chmod +x compare_storage.sh
./compare_storage.sh
```

⌨️ **Option 2 - Or run commands directly:**

```bash
# Legacy storage
az storage account show \
  --name $(az storage account list -g $rg --query "[?starts_with(name, 'legacy')].name" -o tsv) \
  --resource-group $rg \
  --query "{TLS:minimumTlsVersion, PublicAccess:allowBlobPublicAccess}" \
  --output table

# Secure storage  
az storage account show \
  --name $(az storage account list -g $rg --query "[?starts_with(name, 'safe')].name" -o tsv) \
  --resource-group $rg \
  --query "{TLS:minimumTlsVersion, PublicAccess:allowBlobPublicAccess}" \
  --output table
```

---

## 📝 Task 4: Clean Up Legacy Infrastructure (5 minutes)

Now that the secure infrastructure is verified, we can remove the insecure legacy container.

⚠️ **Important:** We're only removing the CONTAINER (raw-insecure), not the entire storage account (yet).

⌨️ **Run:**

```bash
LEGACY_STORAGE=$(az storage account list -g $rg --query "[?starts_with(name, 'legacy')].name" -o tsv)

az storage container delete \
  --account-name $LEGACY_STORAGE \
  --name raw-insecure \
  --auth-mode login
```

✅ **Checkpoint:** Container deleted successfully

---

## ✅ Checkpoint: What You've Accomplished

- [ ] Deployed secure template to dev environment
- [ ] Verified TLS 1.2 is enforced
- [ ] Verified public access is blocked
- [ ] Confirmed container is private
- [ ] Removed insecure legacy container

---

## 🤔 Reflection

**Think about:**
- Why did we deploy the NEW secure storage before removing the OLD insecure one?
- **Answer:** 

---

## 🔗 Next Steps

Your secure infrastructure is deployed! Now it's time to document it for the operations team.

Move to [Activity 9: Governance Handoff](../activity-9/activity-9_start.md)

---

## 🚀 Extension Challenge (Optional)

Try deploying to a "test" environment:

```bash
az deployment group what-if \
  --resource-group $rg \
  --template-file main_secure.bicep \
  --parameters env=test

# If looks good:
az deployment group create \
  --resource-group $rg \
  --template-file main_secure.bicep \
  --parameters env=test \
  --name secure-test-deployment
```

You'll now have both `safedev...` and `safetest...` storage accounts!
