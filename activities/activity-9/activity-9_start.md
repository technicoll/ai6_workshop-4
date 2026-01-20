# Activity 9: Governance Handoff

**Primary KSBs:** S16 (Transition prototypes into the live environment), B4 (Acts with integrity, giving due regard to legal, ethical and regulatory requirements)

---

## 🎯 Learning Objective

Create governance handoff documentation that enables operations teams to maintain and promote the infrastructure to live

---

## 📖 Why Handoff Documentation Matters

You've built secure infrastructure, but your work isn't done until the operations team can:
- Understand what you built and why
- Maintain it confidently
- Promote it to live environments
- Respond to incidents

**Think of it like:** Writing a user manual for the infrastructure you've created.

---

## 📝 Task 1: Create HANDOFF.md

Create a file called `HANDOFF.md` that documents your secure infrastructure.

⌨️ **Create the file:**

```bash
code HANDOFF.md
```

---

### Use This Template

````markdown
# Raw Data Landing Zone - Governance Handoff

**Date:** [Today's date]
**Environment:** Dev
**Owner:** ML Engineering Team
**Reviewer:** [Your name]

---

## Executive Summary

This document describes the secure raw data landing zone infrastructure deployed to the dev environment. This landing zone replaces the legacy insecure storage configuration and is ready for promotion to test and live environments.

---

## Architecture Overview

**Purpose:** Secure storage for external data vendors to upload files before ML pipeline processing.

**Key Components:**
1. **Storage Account:** `safedev[uniquestring]`
2. **Container:** `raw-dev`
3. **Access Control:** Azure AD + RBAC (no SAS tokens)
4. **Security:** TLS 1.2, no public access

📊 **Diagram:** [Link to secure data flow diagram]

---

## Security Properties

### Account-Level Security
- ✅ `allowBlobPublicAccess: false` - Blocks anonymous access
- ✅ `minimumTlsVersion: 'TLS1_2'` - Protects against protocol attacks
- ✅ `kind: 'StorageV2'` - Modern storage type with advanced features

### Container-Level Security
- ✅ `publicAccess: 'None'` - Private by default
- ✅ Access via Azure AD + RBAC only

### Governance Tags
- `environment: dev`
- `owner: ml-engineering-team`
- `costCentre: ml-ops`
- `managedBy: IaC`

---

## Deployment Process

### Prerequisites
- Azure environment (Cloud Shell or Codespaces with Azure CLI)
- Resource group: `$rg` variable set
- Bicep file: `main_secure.bicep`

### Deploy to Dev
```bash
az deployment group create \
  --resource-group $rg \
  --template-file main_secure.bicep \
  --parameters env=dev \
  --name secure-deployment
```

### Deploy to Test
```bash
# 1. Run what-if validation
az deployment group what-if \
  --resource-group $rg \
  --template-file main_secure.bicep \
  --parameters env=test

# 2. If validation passes, deploy
az deployment group create \
  --resource-group $rg \
  --template-file main_secure.bicep \
  --parameters env=test \
  --name secure-test-deployment
```

### Deploy to Live
**⚠️ IMPORTANT:** Requires additional approval from InfoSec and Platform teams.

1. Run `what-if` validation
2. Review with security team
3. Get sign-off from platform team
4. Deploy during change window
5. Verify all security properties
6. Document deployment in change log

---

## Access Management

### For External Vendors (Upload)
Assign RBAC role: **Storage Blob Data Contributor**

```bash
az role assignment create \
  --assignee <vendor-user-id> \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/.../resourceGroups/$rg/providers/Microsoft.Storage/storageAccounts/safedev..."
```

### For Data Scientists (Read)
Assign RBAC role: **Storage Blob Data Reader**

```bash
az role assignment create \
  --assignee <user-id> \
  --role "Storage Blob Data Reader" \
  --scope "/subscriptions/.../resourceGroups/$rg/providers/Microsoft.Storage/storageAccounts/safedev..."
```

### Revoking Access
```bash
az role assignment delete \
  --assignee <user-id> \
  --role "Storage Blob Data Reader" \
  --scope "/subscriptions/.../resourceGroups/$rg/providers/Microsoft.Storage/storageAccounts/safedev..."
```

---

## Verification Checklist

Before promoting to live, verify:

- [ ] `minimumTlsVersion` is `TLS1_2`
- [ ] `allowBlobPublicAccess` is `false`
- [ ] Container `publicAccess` is `None`
- [ ] Governance tags are present
- [ ] RBAC roles are assigned correctly
- [ ] No SAS tokens are in use
- [ ] Audit logging is enabled

---

## Troubleshooting

### Issue: Deployment fails with policy error
**Solution:** Verify resource group is in East US region (Pluralsight P8 restriction)

### Issue: User can't access container
**Solution:** Check RBAC role assignments with:
```bash
az role assignment list --assignee <user-id> --scope <storage-account-resource-id>
```

### Issue: What-if shows unexpected deletions
**Solution:** STOP! Review template changes before proceeding.

---

## Compliance & Standards

This infrastructure complies with:
- **CIS Azure Foundations Benchmark:** 3.1, 3.7, 3.8
- **NIST Cybersecurity Framework:** PR.AC-4, PR.DS-2
- **PCI-DSS:** Requirement 4.1 (TLS 1.2+)

---

## Maintenance & Updates

### Monthly Review
- Review RBAC assignments (remove inactive users)
- Check audit logs for anomalies
- Verify tags are up to date

### Template Updates
1. Update `main_secure.bicep`
2. Run `what-if` validation
3. Review changes with team
4. Deploy to dev first
5. Promote to test/live after verification

---

## Contacts

- **Infrastructure Owner:** ML Engineering Team
- **Security Contact:** InfoSec Team
- **Platform Support:** Platform Team
- **Emergency Contact:** [On-call engineer]

---

## Audit Trail

| Date | Action | Environment | Approver |
|------|--------|-------------|----------|
| [Today] | Initial deployment | dev | [Your name] |
| | | test | |
| | | live | |

---

## Appendices

### A. Template Source
File: `main_secure.bicep`
Repository: [Git repo URL]
Commit: [Git commit hash]

### B. Related Documentation
- [Setup Guide](../../docs/setup_guide.md)
- [Troubleshooting Guide](../../docs/troubleshooting.md)
- [Security Audit](../../activities/activity-1/)
````
---

## ✅ Checkpoint

Your HANDOFF.md should include:

- [ ] Architecture overview with purpose
- [ ] Security properties (all fixes documented)
- [ ] Deployment commands for dev/test/live
- [ ] RBAC access management instructions
- [ ] Verification checklist
- [ ] Troubleshooting section
- [ ] Compliance standards referenced
- [ ] Contact information

---

## 🤔 Reflection

**Think about:**
- If you left the company tomorrow, could the ops team maintain this?
- What information would be most valuable during an incident?

---

## 🔗 Next Steps

Final activity: Reflect on industry standards and frameworks!

Move to [Activity 10: Reflection & Standards](../activity-10/activity-10_start.md)
