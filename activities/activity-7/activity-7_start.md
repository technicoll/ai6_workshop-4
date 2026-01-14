# Activity 7: Staging Gate (what-if)

**Primary KSB:** S10 (validate fitness for purpose)

---

## 🎯 Learning Objective

Use Azure's `what-if` validation to preview infrastructure changes before deploying

---

## 📖 What is `what-if`?

`what-if` is like **git diff** for infrastructure - it shows you what will change **before** you make the change.

**Think of it like:** A dry-run, rehearsal, or preview.

**Why it matters:**
- Prevents accidental deletions
- Catches configuration mistakes
- Provides a safety gate before production

📊 **See the concept:** [what-if Safety Gate Diagram](../../diagrams/ascii_diagrams.md#6-what-if-as-a-safety-gate-for-activity-7)

---

## 📝 Task 1: Run what-if

### Step 1: Run what-if Validation

⌨️ **Run:**

```bash
az deployment group what-if \
  --resource-group $rg \
  --template-file main_secure.bicep \
  --parameters env=dev
```

⏱️ **This takes 30-60 seconds**

---

### Step 2: Interpret the Output

You'll see output like:

```
Resource and property changes are indicated with this symbol:
  + Create
  ~ Modify
  - Delete

The deployment will update the following scope:

Scope: /subscriptions/.../resourceGroups/1-e58d5f37-playground-sandbox

  + Microsoft.Storage/storageAccounts/safedevg4k7m9x2pq3s [2021-09-01]

      location:                  "eastus"
      name:                      "safedevg4k7m9x2pq3s"
      properties.allowBlobPublicAccess:     false
      properties.minimumTlsVersion:         "TLS1_2"
      tags.environment:          "dev"
      tags.owner:                "ml-engineering-team"

  + Microsoft.Storage/storageAccounts/safedevg4k7m9x2pq3s/blobServices/default [2021-09-01]

  + Microsoft.Storage/storageAccounts/safedevg4k7m9x2pq3s/blobServices/default/containers/raw-dev [2021-09-01]

      properties.publicAccess:   "None"

Resource changes: 3 to create.
```

✅ **Checkpoint:** You should see **3 resources to create**, with **0 to delete** (and possibly **x to ignore**).

---

### Step 3: Verify Security Properties

Look for these lines in the what-if output:

```
properties.allowBlobPublicAccess:     false    ✅
properties.minimumTlsVersion:         "TLS1_2" ✅
properties.publicAccess:              "None"   ✅
```

If you see these, your secure template is ready to deploy!

---

## 🤔 What If Something Unexpected Shows Up?

**Scenario:** You see `- Delete` for a resource you need.

**What to do:**
1. **STOP** - Don't deploy!
2. Review your template - what changed?
3. Fix the template
4. Re-run `what-if`
5. Only deploy when preview looks correct

**This is the safety gate in action!**

---

## 📝 Task 2: Compare Different Environments (10 minutes)

Let's see how parameters affect the output.

### Test Environment

⌨️ **Run:**

```bash
az deployment group what-if \
  --resource-group $rg \
  --template-file main_secure.bicep \
  --parameters env=test
```

**Notice:**
- Different storage account name: `securetestg4k7m9x2pq3s`
- Different container name: `raw-test`
- Different tag: `tags.environment: "test"`
- **Same security properties!** (TLS1_2, no public access)

---

## ✅ Checkpoint: Understanding what-if

Answer these questions:

1. What does `+ Create` mean?
1. What does `- Delete` mean?
1. What does `~ Modify` mean?
1. When should you run what-if?

---

## 🤔 Reflection

**Think about:**
- What would happen if you deployed without running what-if first?
- How is what-if like `git diff` before `git push`?

---

## 🔗 Next Steps

Your template is validated! Time to deploy it securely.

Move to [Activity 8: Secure Deployment](../activity-8/activity-8_start.md)

---

## 🚀 Extension Challenge (Optional)

Try running what-if with different parameter values:

```bash
# Live environment
az deployment group what-if \
  --resource-group $rg \
  --template-file main_secure.bicep \
  --parameters env=live owner=platform-team
```

Notice how the output changes based on parameters!
