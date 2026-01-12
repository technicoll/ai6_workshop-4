# Activity 2: Simulating Inherited Problem

**Primary KSB:** S8 (context), S16 (setup)

---

## 🎯 Learning Objective

Deploy an *insecure* infrastructure template to simulate inheriting a brownfield system

---

## 📖 What is Infrastructure as Code (IaC)?

**What:** IaC means describing cloud resources (like storage accounts and containers) in text files instead of clicking through web portals.

**Why it matters:**
- ✅ **Repeatable:** Same file = same result every time
- ✅ **Version controlled:** Track who changed what and when
- ✅ **Reviewable:** Team can spot problems before deployment

**Why NOT just use the Azure Portal?**
Imagine your colleague set up storage by clicking 47 buttons. Now you need to create the same setup in a test environment. Which buttons? What order? What values? With IaC, you have the exact recipe.

**Think of it like:** A Dockerfile vs. installing software manually.

⌨️ **In this activity:** You'll deploy a Bicep file (Azure's IaC language) that creates an *intentionally insecure* storage account. This simulates what might happen inheriting someone else's work. Even if such poor practice is unlikely, the remediation patterns you'll learn apply to real-world security gaps of any severity.

---

## 🏗️ What is Bicep?

**Bicep** is a domain-specific language that uses declarative syntax to deploy Azure resources. It's:
- Cleaner than raw JSON (ARM templates)
- Type-checked (catches errors before deployment)
- Natively integrated with Azure

📖 Learn more about Bicep here: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep

📖 Here is a great pluralsight course covering Bicep and contrasts it to alternatives like Terraform https://app.pluralsight.com/ilx/video-courses/54ca06a4-9902-4cdd-9e74-1e052cc0be24/course-overview

**Example comparison:**

**JSON (ARM Template):** 50+ lines of verbose configuration
**Bicep:** ~15 lines of readable code

💡 **You don't need to be a Bicep expert for this workshop** - we'll guide you through step-by-step.

---

## 📝 Task 0: Environment Setup (Optional for Codespaces Users)

**🌐 Cloud Shell users:** Skip to Task 1 - you're already authenticated!

**💻 Codespaces users:** Complete this one-time setup:

### Install Azure CLI (if not already done)

⚠️ **Note:** If you are blocked for any reason, Cloud Shell in the Azure Portal is a fully supported alternative!

⌨️ **Run:**

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

⏱️ **Takes 2-3 minutes**

✅ **Checkpoint:** Verify installation:

```bash
az version
```

---

### Authenticate with Azure

⌨️ **Run:**

```bash
az login
```

Follow the browser prompt and enter the code, then sign in with your Pluralsight sandbox credentials.

✅ **Checkpoint:** You should see JSON output listing your subscriptions, select number 1.

---

### Verify Working Directory

⌨️ **Check you're in the workshop root:**

```bash
pwd
```

✅ **Expected:** `/workspaces/ai6_workshop-4` (or similar path ending in `ai6_workshop-4`)

If not, navigate to it:

```bash
cd /workspaces/ai6_workshop-4
```

---

## 📝 Task 1: Verify Your Environment (5 minutes)

Before deploying anything, let's make sure your environment is properly configured.

### Step 1: Check Resource Group Variable

⌨️ **Run this command:**

```bash
echo $rg
```

✅ **Checkpoint:** You should see output like `1-e58d5f37-playground-sandbox`

⚠️ **If you see nothing:** Your `$rg` variable isn't set. Run:

```bash
export rg=$(az group list --query "[0].name" -o tsv)
echo $rg
```

📖 This uses the az group list command you can read about here: https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-cli#list-resource-groups

Then run this again

```bash
echo $rg
```

Now compare the resource group name that appears to the only resource group in your Azure portal they should be the same. 

📖 A resource group in Azure is "a container that holds related resources for an Azure solution" https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#what-is-a-resource-group

---

### Step 2: Capture and Verify Your Region

⌨️ **Run these commands:**

```bash
export LOCATION=$(az group show --name $rg --query location -o tsv)
echo "Region: $LOCATION"
```

✅ **Checkpoint:** You should see your resource group's region (commonly `eastus`, `southcentralus`, etc. in Pluralsight)

💡 **Best Practice:** Storing the region in a variable ensures your deployments use the correct location automatically.

---

## 📝 Task 2: Create the Legacy Template (15 minutes)

Now you'll create the insecure Bicep template that simulates Sam's ClickOps setup.

### Step 1: Create the File

⌨️ **Open a blank file in your editor:**

```bash
code legacy.bicep
```

**🌐 Cloud Shell:** Opens in built-in browser editor
**💻 Codespaces:** Opens in VS Code editor

📖 Running `code legacy.bicep` opens the file (creating it first if it doesn't already exist) in different editors depending on your environment. In VS Code's integrated terminal, it opens the file in VS Code itself. In Azure Cloud Shell, it opens the file in the portal's built-in Monaco* editor, a lightweight browser-based code editor.

📖 * https://learn.microsoft.com/en-us/azure/cloud-shell/using-cloud-shell-editor

⚠️ **Note:** If you are doing this in the Cloud Shell you may be asked to use the legacy Cloud Shell. This is fine to accept.

---

### Step 2: Copy the Template

Copy the entire content from [templates/legacy.bicep](../../templates/legacy.bicep) and paste it into the editor.

💡 **Quick way to copy:**
1. Open [templates/legacy.bicep](../../templates/legacy.bicep) in a new tab
2. Select all (Ctrl+A or Cmd+A)
3. Copy (Ctrl+C or Cmd+C)
4. Paste into your editor (Ctrl+V or Cmd+V)

---

### Step 3: Save the File

**🌐 Cloud Shell:** Ctrl+S
**💻 Codespaces:** Press Ctrl+S (Cmd+S on Mac)

✅ **Checkpoint:** The file should now exist in your current directory.

⌨️ **Verify with:**

```bash
ls -l legacy.bicep
```

---

## 📝 Task 3: Deploy the Legacy Template (10 minutes)

Now let's deploy this insecure infrastructure to your sandbox.

### Step 1: Deploy Using Azure CLI

⌨️ **Run this command:**

```bash
az deployment group create \
  --resource-group $rg \
  --template-file legacy.bicep \
  --name legacy-deployment
```

⏱️ **This will take 1-2 minutes.** You'll see progress output as Azure creates the resources.

⚠️ **Expected Warning: BCP035**

You may see a warning like:
```
Warning BCP035: Missing property "kind" in resource definition
```

💡 **This is intentional!** The legacy template is missing the `kind` property to reinforce that it's old/incomplete code. The deployment will still succeed.

📖 While it deploys this is a great opportunity to read the docs for the command you just ran: `az deployment group create` https://learn.microsoft.com/en-us/cli/azure/deployment/group?view=azure-cli-latest#az-deployment-group-create 

💡 Getting comfortable with official docs is a superpower 🦸‍♀️! You'll be able to:
- Ground your understanding in authoritative **primary sources**
- Verify AI-generated suggestions
- Ask the AI more informed questions

💡 From here on, we'll stop linking to official docs for every command. But keep building the habit of looking things up yourself—it will serve you well beyond any tutorial. This applies to all commonly used tools in MLOps, for instance:
- Azure CLI
- AWS CLI
- scikit-learn
- MLflow
- pandas
- polars
- transformers (HuggingFace)

Get comfortable navigating official documentation so you can work confidently and independently.

---

### Step 2: Verify Deployment Success

⌨️ **Run this command:**

```bash
az storage account list -g $rg -o table
```

✅ **Checkpoint:** You should see a storage account with a name like `legacy<random-string>`

**Example output:**
```
Name                        Location    ResourceGroup
--------------------------  ----------  -----------------------------
legacyg4k7m9x2pq3s         eastus      1-e58d5f37-playground-sandbox
```

💡 **Why the random string?** The `uniqueString()` function in Bicep generates a hash based on your resource group ID. This ensures globally unique storage account names (required by Azure).

---

### Step 3: Inspect the Container

⌨️ **List containers in the storage account:**

```bash
# Get the storage account name
export STORAGE_ACCOUNT=$(az storage account list -g $rg --query "[0].name" -o tsv)
echo "Storage account: $STORAGE_ACCOUNT"

# List containers
az storage container list \
  --account-name $STORAGE_ACCOUNT \
  --auth-mode login \
  --query "[].{Name:name, PublicAccess:properties.publicAccess}" \
  --output table
```

✅ **Checkpoint:** You should see a container called `raw-insecure` with `PublicAccess: blob`

⚠️ **This means anyone with the URL can read files!** That's one of the vulnerabilities you likely identified in Activity 1.

---

## 🔒 Observe the Insecure Properties

Let's verify the specific vulnerabilities we identified in Activity 1:

### Check TLS Version

⌨️ **Run:**

```bash
az storage account show \
  --name $STORAGE_ACCOUNT \
  --resource-group $rg \
  --query "{Name:name, TLS:minimumTlsVersion, PublicAccess:allowBlobPublicAccess}" \
  --output table
```

✅ **Checkpoint:** You should see:
- `TLS: TLS1_0` ❌ (Vulnerable!)
- `PublicAccess: True` ❌ (Insecure!)

---

## 🤔 Reflection

You've just deployed insecure infrastructure! In the real world, this is exactly what might happen when systems are built through manual portal clicking without oversight.

**Think about:**
- How easy was it to deploy insecure infrastructure?
- If Sam had used IaC from the start, would the security review have caught these issues earlier?
- What if this template was committed to git - could your team (or even an AI tool) review it before deployment?

---

## ✅ Checkpoint: What You've Accomplished

Before moving to Activity 3, make sure you have:

- [ ] Verified your `$rg` variable is set
- [ ] Created `legacy.bicep` in your workspace
- [ ] Successfully deployed the legacy template
- [ ] Verified a storage account named `legacy<random>` exists
- [ ] Confirmed the container `raw-insecure` has public access
- [ ] Observed that TLS 1.0 is enabled (insecure!)

---

## 🔗 Next Steps

🎓 **Well done!** You've simulated inheriting an insecure brownfield system.

In the next activity, you'll:
- Export the configuration to JSON
- Learn about the "Two-Lane Model" (patch vs. refactor)
- Understand why we'll choose the refactor approach

Move to [Activity 3: Introspection](../activity-3/activity-3_start.md)

---

## 🚀 Extension Challenge (Optional)

Try inspecting the raw JSON of your deployment:

```bash
az deployment group show \
  --resource-group $rg \
  --name legacy-deployment \
  --output json > deployment-output.json
code deployment-output.json
```

**🌐 Cloud Shell:** Opens in built-in browser editor
**💻 Codespaces:** Opens in VS Code editor

Look at the `"properties": {` section - what information does Azure provide?

---

## 🔗 Next Activity

Now that you've deployed the insecure infrastructure, it's time to introspect it!

Move to [Activity 3: Introspection](./activity-3/activity-3_start.md) to:
- Export your deployed resources to JSON
- Learn about the "Two-Lane Model" (patch vs. refactor)
- Understand why we'll choose the refactor approach
