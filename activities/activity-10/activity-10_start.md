# Activity 10: Reflection & Standards

**Primary KSBs:** K13 (security standards), B4 (integrity)

---

## 🎯 Learning Objective

Connect the practical security fixes from this workshop to industry security standards and frameworks

---

## 📖 From Practice to Principle

Throughout this workshop, you've made specific security fixes:
- Blocked public access
- Enforced TLS 1.2
- Used RBAC instead of SAS tokens

But **why** are these considered security best practices? Let's connect your work to industry standards.

---

## 📝 Task 1: Map Fixes to Standards (20 minutes)

For each security fix you made, identify which industry standards require it.

### Fix #1: Blocked Public Access

**What you did:** `allowBlobPublicAccess: false`

**Industry standards that require this:**

**CIS Microsoft Azure Foundations Benchmark:**
- Control 3.1: "Ensure that 'Public access level' is set to Private for blob containers"
- Control 3.7: "Ensure that 'Public access level' is disabled for storage accounts"

**NIST Cybersecurity Framework:**
- PR.AC-4: "Access permissions and authorizations are managed"
- PR.DS-2: "Data-in-transit is protected"

**Why it matters:**
Public access = unauthorised data exposure. These standards exist because data breaches from misconfigured cloud storage are one of the most common security incidents.

---

### Fix #2: Enforced TLS 1.2

**What you did:** `minimumTlsVersion: 'TLS1_2'`

**Industry standards that require this:**

**PCI-DSS (Payment Card Industry Data Security Standard):**
- Requirement 4.1: "Use strong cryptography and security protocols to safeguard sensitive cardholder data during transmission over open, public networks"
- Specifically: TLS 1.2+ required since June 2018

**NIST SP 800-52 Rev. 2:**
- Recommends TLS 1.2 as minimum (TLS 1.3 preferred)
- Prohibits TLS 1.0 and 1.1

**Why it matters:**
TLS 1.0 has known vulnerabilities (BEAST, POODLE, Sweet32). Using deprecated protocols exposes data in transit to interception attacks.

---

### Fix #3: Used RBAC Instead of SAS Tokens

**What you did:** Azure AD + RBAC roles (not hardcoded tokens)

**Industry standards that require this:**

**NIST Cybersecurity Framework:**
- PR.AC-1: "Identities and credentials are issued, managed, verified, revoked, and audited"
- PR.AC-4: "Access permissions are managed, incorporating principles of least privilege"

**CIS Controls:**
- Control 6.1: "Establish access granting process"
- Control 6.2: "Establish access revoking process"

**Why it matters:**
Hardcoded tokens = shared secrets that can't be easily revoked, no audit trail, and violation of least-privilege principle.

---

## 🤔 Reflection Questions

### Q1: The Two-Lane Model

**Reflect:** When you inherit insecure infrastructure in the future, which lane will you choose and why?

**Think about:**
- Is the system in production serving users?
- Is there time pressure (security breach vs. planned refactor)?
- Will this need to be promoted to other environments?

**Lane 2 (refactor) is almost always the right choice** - except during active incidents.

---

### Q2: Security Invariants

**Reflect:** Why should security properties NEVER be parameters?

**Think about:**
- What happens if someone deploys with `--parameters allowBlobPublicAccess=true`?
- Should security be "configurable"?

**Answer:** Security properties should be **locked in code**, not configurable. If you need different security for dev vs live, you're doing it wrong.

---

### Q3: From Workshop to EPA

**Reflect:** How do the skills from this workshop apply to your EPA project?

**Think about:**
- Will you need to deploy cloud infrastructure?
- How will you document security decisions?
- Who will review your infrastructure code?
- How will you demonstrate compliance with standards?

**Your EPA assessors will expect:**
- Evidence of security-first design (KSB S8, K13)
- Documentation of architecture decisions
- Compliance with relevant standards
- Governance handoff documentation (KSB S16, B4)

---

## 📝 Task 2: Create Your Reflection Document (10 minutes)

Create a file called `REFLECTION.md` with your thoughts:

```markdown
# Workshop 4 Reflection

## Key Learnings

1. **Most important thing I learned:**
   [Your reflection]

2. **How this connects to industry standards:**
   [Specific standards you now understand]

3. **Application to my EPA:**
   [How you'll use these skills]

## The Two-Lane Model

**My understanding:**
[Explain Lane 1 vs Lane 2 in your own words]

**When to use each:**
[Your decision framework]

## Security Invariants

**Why they matter:**
[Your explanation]

## Questions I Still Have

1. [Question 1]
2. [Question 2]
```

---

## 🎓 Congratulations!

You've completed Workshop 4: Secure ML Data Pipelines with IaC!

### What You've Accomplished

✅ **Audited** legacy infrastructure for vulnerabilities (S8)

✅ **Deployed** both insecure and secure infrastructure

✅ **Refactored** using Lane 2 approach (clean baseline)

✅ **Parameterised** templates for environment promotion

✅ **Validated** with `what-if` before deploying (S10)

✅ **Deployed** secure infrastructure (S16)

✅ **Documented** governance handoff (B4)

✅ **Connected** to industry standards (K13)

---

## 📚 Further Learning

### Standards & Frameworks
- [CIS Azure Foundations Benchmark](https://www.cisecurity.org/benchmark/azure)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [PCI-DSS](https://www.pcisecuritystandards.org/)
- [ISO 27001/27002](https://www.iso.org/isoiec-27001-information-security.html)

### Azure Bicep
- [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Bicep Best Practices](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/best-practices)

### Security
- [Azure Security Baseline](https://learn.microsoft.com/en-us/security/benchmark/azure/)
- [OWASP Cloud Security](https://owasp.org/www-project-cloud-security/)

---

**🎉 Well done!** You've taken a major step toward becoming a security-conscious infrastructure engineer.
