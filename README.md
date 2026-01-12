# Workshop 4: Secure ML Data Pipelines with IaC

---

## 🖥️ Environment Options

This workshop supports two equally valid environments:

**🌐 Option 1: Azure Cloud Shell (Browser-Based)**
- No setup required
- Pre-authenticated with Azure
- Built-in editor
- Automatic storage provisioning

**💻 Option 2: GitHub Codespaces (VS Code)**
- Fork this repository via GitHub Classroom link (provided separately)
- Open your copy of the repo in a GitHub Codespace
- Requires Azure CLI installation and `az login`
- Uses VS Code editor

ℹ️ **Note:** If Codespaces doesn't work for you (e.g. corporate block), Cloud Shell is a fully supported alternative.

📖 **Setup Instructions:** Follow [Setup Guide](docs/setup_guide.md) for detailed steps for both options.

---

## 🎯 Workshop Overview

In this workshop, you'll transform an insecure legacy data pipeline into a secure, governed baseline using Infrastructure as Code (IaC). You'll learn to audit cloud infrastructure, identify security vulnerabilities, and refactor systems using Azure Bicep templates with security-first principles.

### What You'll Learn

By the end of this workshop, you'll be able to:

- 🔍 Audit cloud infrastructure for security vulnerabilities
- 🏗️ Write secure Azure Bicep templates
- 🔐 Implement security-first infrastructure patterns
- 🔄 Parameterise templates for environment promotion (dev → test → live)
- ✅ Use `what-if` validation as a deployment safety gate
- 📋 Deliver governance handoff documentation for live systems

### Key Skills, Behaviours & Knowledge (KSBs)

- **S8:** Assess system vulnerabilities and weaknesses
- **K13:** Standards and frameworks for information security
- **S16:** Initiate, design, and document transition to live operation
- **S10:** Validate appropriateness and quality of systems
- **B4:** Consistency and integrity in every aspect of work

---

## 📚 Workshop Structure

### Morning: "The Audit" (Reactive & Insecure)

Discover what you've inherited and identify the problems.

| Activity | Title | Time | Focus |
|----------|-------|------|-------|
| **1** | [Legacy Audit](activities/activity-1/) | 09:30-10:00 | Spot vulnerabilities in diagrams |
| **2** | [Simulating Inherited Problem](activities/activity-2/) | 10:00-10:30 | Deploy insecure infrastructure |
| **3** | [Introspection](activities/activity-3/) | 10:45-11:15 | Examine deployed resources |
| **4** | [Secure Refactor Phase 1](activities/activity-4/) | 11:15-12:00 | Build clean baseline template |
| **5** | [Pipeline Sketch](activities/activity-5/) | 12:00-12:30 | Design secure data flow |

### Afternoon: "The Refactor" (Proactive & Standards-Based)

Build secure, repeatable infrastructure that meets governance standards.

| Activity | Title | Time | Focus |
|----------|-------|------|-------|
| **6** | [Parameterisation](activities/activity-6/) | 13:30-14:00 | Make templates reusable |
| **7** | [Staging Gate (what-if)](activities/activity-7/) | 14:00-14:30 | Validate before deploying |
| **8** | [Secure Deployment](activities/activity-8/) | 14:30-15:15 | Deploy secure infrastructure |
| **9** | [Governance Handoff](activities/activity-9/) | 15:15-16:00 | Document for operations |
| **10** | [Reflection & Standards](activities/activity-10/) | 16:00-16:30 | Connect to industry standards |

---

## 🚗 The Two-Lane Teaching Model

This workshop teaches you **two approaches** to fixing insecure infrastructure:

- **Lane 1: Patch Export** (Emergency fix) - Export JSON, patch bad bits, redeploy
  - ✅ Fast
  - ❌ Brittle, not repeatable, full of metadata noise
  - Use when: Production is down and needs immediate fix

- **Lane 2: Refactor to Standard** (Enterprise way) - Build clean baseline from scratch
  - ✅ Repeatable, reviewable, standards-based
  - ✅ Can be promoted across dev → test → live
  - Use when: **Always** (default approach)

**This workshop focuses on Lane 2**, teaching you the sustainable, professional approach to infrastructure security.

---

## 📖 Emoji Guide

This workshop uses emojis to help you quickly scan and understand content types:

| Emoji | Meaning |
|-------|---------|
| 🎯 | **Learning Objective** - What you'll be able to do |
| 📋 | **Expected Outputs** - Deliverables to create |
| 📝 | **Task/Step** - Action item - do this now |
| ⌨️ | **Terminal Command** - Run this in Cloud Shell |
| 💻 | **Code/Template** - Code snippet or template to use |
| ✅ | **Checkpoint** - Verify your progress |
| 🤔 | **Reflect** - Deep thinking prompt |
| 💡 | **Tip/Hint** - Helpful suggestion |
| ⚠️ | **Warning** - Common mistake to avoid |
| 🔒 | **Security** - Security-related concept |
| 📖 | **Explanation** - Background theory |
| 🚀 | **Extension** - Optional advanced challenge |
| 🎓 | **Complete** - Activity completion marker |

---

## 🛠️ Getting Started

### Workshop Setup

Follow the [Setup Guide](docs/setup_guide.md)

---

## 📁 Repository Structure

```
ai6_workshop-4/
├── README.md                     # This file
├── user_brief.md                 # "Project Legacy" scenario
├── activities/                   # 10 activities with _start.md and _solution.md
├── templates/                    # Bicep templates (legacy, starter, complete)
├── docs/                         # Setup, troubleshooting, emoji guide
└── diagrams/                     # ASCII diagrams for visual reference
```

---

## 🎯 Learning Outcomes

By completing this workshop, you'll have:

1. **Audited** legacy infrastructure for security vulnerabilities
2. **Deployed** both insecure (legacy) and secure infrastructure templates
3. **Refactored** insecure infrastructure into a clean, secure baseline
4. **Parameterised** templates for reuse across environments
5. **Validated** infrastructure changes using `what-if` before deployment
6. **Deployed** secure, standards-based infrastructure
7. **Documented** governance handoff for operations teams
8. **Reflected** on industry security standards (CIS, NIST, PCI-DSS)

---

## 📚 Additional Resources

- [Azure Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure Security Best Practices](https://learn.microsoft.com/en-us/azure/security/fundamentals/best-practices-and-patterns)
- [CIS Azure Foundations Benchmark](https://www.cisecurity.org/benchmark/azure)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

---


**Ready to begin?** 

1. Read the [Project Legacy scenario](user_brief.md).
2. Follow the [Setup Guide](docs/setup_guide.md)
3. Start with [Activity 1: Legacy Audit](activities/activity-1/activity-1_start.md)
