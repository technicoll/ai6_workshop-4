# Activity 5: Pipeline Sketch (Design Check)

**Primary KSB:** S10 (fitness for purpose), S16

---

## 🎯 Learning Objective

Draw a simple data flow diagram showing the secure landing zone architecture with identity boundaries

---

## 📖 Why Sketch Before Deploying?

You've written a secure template. Before deploying it, let's make sure you understand *why* it's secure and *how* it works.

**Think of it like:** Reviewing a recipe before cooking. "Wait, do I have all the ingredients? Is this oven temperature right?"

**What we're checking:**
- ✅ Where does data come from?
- ✅ Where does it land?
- ✅ Who can access it (and how)?
- ✅ Where are the security boundaries?

---

## 📝 Task 1: Review the Secure Architecture (10 minutes)

First, let's look at what a secure data flow SHOULD look like.

📊 **Open this diagram:** [Secure Data Flow](../../diagrams/ascii_diagrams.md#3-secure-data-flow-target-architecture)

### Key Security Properties

Compare this secure flow with the legacy flow from Activity 1:

**Secure (Target):**
- 🔐 Identity boundary (Azure AD + RBAC)
- 🔐 No public access
- 🔐 TLS 1.2 enforced
- 🔐 Auditable access logs
- 🔐 Centrally managed credentials

**Legacy (What we had):**
- ❌ Public endpoints
- ❌ Hardcoded SAS tokens
- ❌ TLS 1.0
- ❌ No audit trail
- ❌ Can't revoke access easily

---

## 📝 Task 2: Sketch Your Understanding

Create a simple diagram showing:

1. **External data source** (vendors/partners)
2. **Your secure storage account**
3. **Downstream consumers** (data scientists/ML engineers)
4. **Identity boundary** (Azure AD/RBAC)

**You can:**
- Draw on paper and take a photo
- Use ASCII art (see examples in diagrams folder)
- Use simple text with arrows (→)

### Minimum Requirements

Your diagram should show:
- [ ] Where external data enters
- [ ] The storage account with container name
- [ ] How authentication works (not SAS tokens!)
- [ ] Who can read the data (and how)

---

## ✅ Checkpoint: Key Understanding

Answer these questions:

1. How do external vendors authenticate?
1. Can someone with just a URL read files?
1. What TLS version is enforced?
1. How do you revoke someone's access?

---


## 🔗 Next Steps

After lunch, we'll parameterise this template for dev/test/live environments!

Then move to [Activity 6: Parameterisation](../activity-6/activity-6_start.md)
