# Activity 3: Introspection - SOLUTION

**Primary KSBs:** S16 (Transition prototypes into the live environment), S8 (Assess system vulnerabilities and mitigate the threats or risks to assets, data and cyber security), K13 (Data and information security standards, ethical practices, policies and procedures relevant to data management activities such as data lineage, data retention and metadata management)

---

## ✅ What You Should Have Found

### In `current_state.json` and `current_state.bicep`:

| Property | Value | Location |
|----------|-------|----------|
| `allowBlobPublicAccess` | `true` | Storage account properties |
| `minimumTlsVersion` | `TLS1_0` | Storage account properties |
| `publicAccess` | `Blob` | Container properties |

### Storage Accounts

**🌐 Cloud Shell users:** You'll see **two** storage accounts:
- `legacy...` → yours (the insecure one to fix)
- `cs...` or with tag `ms-resource-usage: azure-cloud-shell` → Cloud Shell's (ignore)

**💻 Codespaces users:** You'll see **one** storage account (just yours)

---

## 🔧 Troubleshooting

**"Export failed"**  
→ Check `$rg` is set: `echo $rg`

**"Decompile failed"**  
→ Ensure `current_state.json` exists: `ls current_state.json`

**"Can't find TLS1_0"**  
→ Search is case-sensitive. Try `TLS` or `tls`

---

## 🔗 Next Activity

Move to [Activity 4: Secure Refactor Phase 1](../activity-4/activity-4_start.md)
