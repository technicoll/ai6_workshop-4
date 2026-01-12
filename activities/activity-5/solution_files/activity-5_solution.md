# Activity 5: Pipeline Sketch - SOLUTION

---

## ✅ Example Diagram

Here's an example of what your diagram could look like:

```
External Vendors → [Azure AD Auth] → Secure Storage (raw-secure) → [Azure AD Auth] → Data Scientists
                         ↓                      ↓                         ↓
                   RBAC Role            TLS 1.2 Only              RBAC Role
                   (Write Access)       No Public Access          (Read Access)
```

Or more detailed:

```
┌──────────────┐
│  External    │   Upload via Azure AD/RBAC
│  Data Source │ ────────────────┐
│ (Vendors)    │                 │
└──────────────┘                 ▼
                       ┌─────────────────────┐
                       │  Secure Storage     │
                       │  Account            │
                       │  ─────────────      │
                       │  • TLS 1.2 Only     │
                       │  • No Public Access │
                       │  • RBAC Enforced    │
                       │                     │
                       │  Container:         │
                       │  raw-secure         │
                       └─────────────────────┘
                                 │
                                 │ Read via Azure AD/RBAC
                                 ▼
                       ┌─────────────────┐
                       │  Downstream     │
                       │  Consumers      │
                       │  • Data Sci     │
                       │  • ML Engineers │
                       └─────────────────┘
```

---

## 🔐 Key Insights

**Identity Boundary:**
- Everything happens through Azure AD
- No shared secrets (SAS tokens)
- Auditable (know who accessed what, when)

**Security Layers:**
- Account level: No public access allowed
- Container level: Explicitly private
- Transport level: TLS 1.2 enforced
- Access level: RBAC roles only

---

## ✅ Checkpoint: Key Understanding

Answer these questions:

**Q1: How do external vendors authenticate?**
- ✅ Azure AD + RBAC roles (not hardcoded tokens!)

**Q2: Can someone with just a URL read files?**
- ✅ No! Public access is disabled

**Q3: What TLS version is enforced?**
- ✅ TLS 1.2 (not the deprecated TLS 1.0)

**Q4: How do you revoke someone's access?**
- ✅ Remove their RBAC role assignment (instant!)


## 🔗 Next Activity

Move to [Activity 6: Parameterisation](../activity-6/activity-6_start.md)
