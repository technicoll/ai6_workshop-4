# Activity 4: Secure Refactor (Phase 1) - SOLUTION

**Primary KSBs:** K13, S8 (mitigation), S16 (setup)

---

## ✅ Quick Check

Your completed template should have these **three fixes**:

| Fix | Property | Value |
|-----|----------|-------|
| #1 | `allowBlobPublicAccess` | `false` |
| #2 | `minimumTlsVersion` | `'TLS1_2'` |
| #3 | Container `publicAccess` | `'None'` |

Also check:
- [ ] `kind: 'StorageV2'` is set
- [ ] `blobService` resource is uncommented
- [ ] `rawSecure` container resource is uncommented

---

## 📄 Complete Template

See [main_secure_phase1.bicep](main_secure_phase1.bicep) for the full solution.

---

## 🔧 Troubleshooting

**"Bicep validation errors"**  
→ Check for missing commas or typos in property names

**"blobService not found"**  
→ Make sure you uncommented the entire `blobService` resource block

---

## 🔗 Next Activity

Move to [Activity 5: Pipeline Sketch](../activity-5/activity-5_start.md)
