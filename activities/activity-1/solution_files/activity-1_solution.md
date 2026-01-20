# Activity 1: Legacy Audit - SOLUTION

**Primary KSB:** S8 (Assess system vulnerabilities and mitigate the threats or risks to assets, data and cyber security)

---

## ✅ Expected Findings

Your audit should identify these **three core vulnerabilities**:

### 1. Public Blob Access
| | |
|---|---|
| **Location** | Storage container with `publicAccess: 'Blob'` |
| **Risk** | Anyone with the URL can read files - no authentication required |
| **Severity** | HIGH |

### 2. Hardcoded SAS Token
| | |
|---|---|
| **Location** | Access script with embedded token |
| **Risk** | "God mode" permissions (`sp=racwdli`), expires 2099, can't be revoked without breaking all consumers |
| **Severity** | CRITICAL |

### 3. Weak TLS (1.0)
| | |
|---|---|
| **Location** | Storage account `minimumTlsVersion: 'TLS1_0'` |
| **Risk** | Deprecated protocol vulnerable to POODLE/BEAST attacks |
| **Severity** | HIGH |

---

## ✅ Self-Check

- [ ] Did you identify all three vulnerabilities?
- [ ] Did you note **where** each one is in the architecture?
- [ ] Did you explain **what could go wrong** for each?
- [ ] Did you create a `SECURITY_AUDIT.md` file?

**If yes to all → you're ready for Activity 2!**

---

## 🔗 Next Activity

Move to [Activity 2: Simulating Inherited Problem](../activity-2/activity-2_start.md) to deploy this insecure infrastructure in your sandbox.
