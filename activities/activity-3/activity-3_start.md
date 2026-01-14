# Activity 3: Introspection

**Primary KSBs:** S16, S8, K13

---

## 🎯 Learning Objective

Use Azure's export feature to introspect live infrastructure and identify specific misconfigurations

---

## 🚗 The Two-Lane Approach to Fixing Infrastructure

You've just inherited a messy, insecure landing zone. There are **two ways** to fix it:

### Lane 1: "Patch the Export" (Emergency/Quick Fix)
- Export the current config → Fix the bad bits → Redeploy
- ✅ Fast
- ❌ Full of Azure metadata noise (read-only fields, timestamps)
- ❌ Hard to understand
- ❌ Doesn't work well for promoting dev → test → live

### Lane 2: "Refactor to Standard" (Enterprise/Sustainable Fix)
- Study the export to *understand* what's wrong
- Build a clean, secure baseline template from scratch
- ✅ Repeatable across environments
- ✅ Clear and reviewable
- ✅ Becomes the team standard

💡 **This workshop teaches Lane 2.** We'll use exports for *diagnosis*, not as the fix itself.

**When would you use Lane 1?** Production is down, security breach in progress, and you need to patch *right now*. Then you clean it up properly later with Lane 2.

📊 **See the full diagram:** [Two-Lane Teaching Model](../../diagrams/ascii_diagrams.md#2-the-two-lane-teaching-model)

---

## 📖 What is Resource Export?

Azure can export the current state of your resource group to a template file. This is useful for:
- Understanding what's actually deployed (vs. what you thought you deployed)
- Diagnosing configuration issues
- Learning Azure resource structures

⚠️ **Important:** Exported templates are NOT production-ready! They contain:
- Read-only fields (like `provisioningState`)
- Auto-generated values (like endpoints)
- Unnecessary metadata

Think of exports like reverse-engineering a recipe from a finished dish—you can identify every ingredient and its quantity, but you lose the chef's method and intent. In IaC terms, you get a flattened declarative snapshot of *what exists*, but not the clean, purposeful structure you'd write to *declare what you want*.

---

## 📝 Task 1: Export Resource Group (10 minutes)

### Step 1: Export to JSON

⌨️ **Run this command:**
```bash
az group export --name $rg > current_state.json
```

⏱️ **This takes ~30 seconds**

⚠️ **Expected Warning and Error:**
You'll see output like this:
```
WARNING: Export template operation completed with errors. Some resources were not exported.
ERROR: Could not get resources of the type 'Microsoft.Storage/storageAccounts/inventoryPolicies'.
```
This is normal—`inventoryPolicies` is an Azure feature we're not using, and some resource types simply can't be exported. The export still succeeds for the resources we care about.

---

### Step 2: Verify the Export

⌨️ **Check the file exists:**

```bash
ls -lh current_state.json
```

✅ **Checkpoint:** You should see a fiale ~10-20KB in size

---

### Step 3: Peek at the JSON

⌨️ **Open in your editor:**

```bash
code current_state.json
```

**🌐 Cloud Shell:** Opens in built-in browser editor

**💻 Codespaces:** Opens in VS Code editor

💡 **Don't try to read all 300+ lines!** This is why we use search tools.

---

## 📝 Task 2: Find the Vulnerability in JSON (5 minutes)

Let's use search to find the insecure TLS setting.

### Step 1: Search for TLS1_0

In your editor:
1. Press **Ctrl+F** (or Cmd+F on Mac)
2. Type: `TLS1_0`
3. Press Enter

✅ **Checkpoint:** You should find a line like:

```json
"minimumTlsVersion": "TLS1_0",
```

This confirms the vulnerability exists in your live system!

---

### Step 2: Find Public Access

While still in `current_state.json`, search for:
- `allowBlobPublicAccess` - should be `true` (insecure!)
- `publicAccess` - should be `"Blob"` (insecure!)

✅ **Checkpoint:** Found both insecure properties in the JSON

---

## 📝 Task 3: Decompile to Bicep (10 minutes)

Azure can convert JSON templates back to Bicep. This makes them easier to read (but still not production-ready!).

### Step 1: Decompile

⌨️ **Run:**
```bash
az bicep decompile --file current_state.json
```

This creates `current_state.bicep`.

⚠️ **Expected Warnings:**
You'll see output like this:
```
WARNING: Decompilation is a best-effort process, as there is no guaranteed mapping from ARM JSON to Bicep...
...
Warning BCP073: The property "tier" is read-only...
Warning BCP073: The property "sku" is read-only...
Warning no-unnecessary-dependson: Remove unnecessary dependsOn entry...
```
These warnings confirm what we said earlier: exports capture *what exists*, not clean reusable code. In a real scenario, you'd need to fix these before the template could be redeployed.

---

### Step 2: Open the Bicep File

⌨️ **Run:**

```bash
code current_state.bicep
```

**🌐 Cloud Shell:** Opens in built-in browser editor
**💻 Codespaces:** Opens in VS Code editor

💡 **Observation:** This is much more readable than JSON, but still messy!

---

### Step 3: Find the Insecure Storage Account

**🌐 Cloud Shell users:** You'll see **TWO** storage accounts in the file:
1. Your **legacy** account (the insecure one) ✅
2. **Cloud Shell's** storage account (Azure's own) ❌ ignore this

**💻 Codespaces users:** You'll see **ONE** storage account:
1. Your **legacy** account (the insecure one) ✅

🔍 **How to identify the legacy account:**
- Name starts with `legacy...`
- Has `TLS1_0` and `allowBlobPublicAccess: true`

💡 **Tip:** Search for `legacy` (Ctrl+F) to jump to your account

---

### Step 4: Inspect the Insecure Properties

In the `legacy...` storage account resource block, you should find:

```bicep
properties: {
  allowBlobPublicAccess: true    // ❌ Vulnerability #1
  minimumTlsVersion: 'TLS1_0'    // ❌ Vulnerability #2
  // ... lots of other auto-generated properties
}
```

And somewhere below, a container with:

```bicep
properties: {
  publicAccess: 'Blob'           // ❌ Vulnerability #3
}
```

✅ **Checkpoint:** Confirm you've found all three insecure properties

---

## 🤔 Why Two Storage Accounts?

**Q: Why does my sandbox have TWO storage accounts?**

**A:** Azure Cloud Shell needs its own storage to save your files, session history, and configurations. You created a storage account when you first opened Cloud Shell.

**How to identify them:**
- **Your legacy account:** `legacy<randomstring>` - the one YOU deployed
- **Cloud Shell's account:** Has the unique name you gave it on set up.

**Important:** Only worry about fixing YOUR legacy account. Leave Cloud Shell's storage alone!

---

## ⚠️ Why We Won't Edit current_state.bicep

You might be thinking: "Why not just fix the vulnerabilities in `current_state.bicep` and redeploy?"

**Problems with exported templates:**
1. **Read-only fields:** Lines like `provisioningState`, `creationTime` - Azure rejects these on redeploy
2. **Endpoint auto-generation:** URLs like `primaryEndpoints` are generated by Azure, not defined in templates
3. **Metadata noise:** 500 lines when you only need 50
4. **Hard to maintain:** Doesn't parameterize well for dev/test/live

**Lane 2 approach (next activity):** Write a clean, minimal template that defines only what matters.

---

## ✅ Checkpoint: What You've Accomplished

Before moving to Activity 4, make sure you have:

- [ ] Exported the resource group to `current_state.json`
- [ ] Found `TLS1_0` in the JSON
- [ ] Decompiled to `current_state.bicep`
- [ ] Identified your legacy storage account (vs Cloud Shell's)
- [ ] Confirmed all three vulnerabilities exist in the live system
- [ ] Understand why we won't edit `current_state.bicep` directly

---

## 🤔 Reflection

**Think about:**
- How much "noise" did you see in the exported JSON/Bicep?
- Could you easily "promote" this exported template to a test environment?
- What would happen if you tried to redeploy `current_state.bicep` as-is?

**Answer:** It would likely fail with errors about read-only properties! This is why Lane 2 (refactor) is the better approach.

---

## 🔗 Next Steps

🎓 **Well done!** You've introspected your live infrastructure and confirmed the vulnerabilities.

In the next activity, you'll **refactor** to a clean, secure baseline using Lane 2 approach.

Move to [Activity 4: Secure Refactor Phase 1](../activity-4/activity-4_start.md)

---

## 🚀 Extension Challenge (Optional)

Try comparing the decompiled Bicep with your original `legacy.bicep`:

```bash
# Open both files side-by-side
code legacy.bicep
code current_state.bicep
```

**🌐 Cloud Shell:** Opens both in browser editor tabs
**💻 Codespaces:** Opens both in VS Code editor

**Notice:**
- Your original had ~50 lines
- The export has ~300+ lines
- Which is easier to understand and maintain?

This demonstrates why Lane 2 (refactor from scratch) produces cleaner, more maintainable IaC!
