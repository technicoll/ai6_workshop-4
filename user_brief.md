# Project Legacy: The Scenario

## 📖 Background

You've just joined a data team at a mid-sized company. The team is building machine learning pipelines for predictive analytics using cloud infrastructure. Your first task? Audit the existing "raw data landing zone" - the storage infrastructure where external data vendors drop files before they enter the ML pipeline.

## 🔍 What You've Inherited

The previous developer, Sam, left the company three weeks ago. Sam built the landing zone infrastructure six months ago using "ClickOps" (clicking through the Azure Portal). Sam left behind:

- A working storage account that receives data from external vendors
- A Bash script that data scientists use to access the data
- No documentation about how it was built
- No Infrastructure as Code (IaC) templates
- A note that says: "It works, don't touch it!"

## 📊 The Current System

External data vendors (partners who provide taxi trip data, weather data, and location data) upload files to your Azure storage account. Data scientists and ML engineers then download these files to train predictive models.

The system **works** - data flows in, data flows out. But your manager has asked you to:

1. **Audit the security** of the current setup
2. **Document what's there** using Infrastructure as Code
3. **Refactor it** to meet enterprise security standards
4. **Prepare it** for promotion to the live environment

## ⚠️ The Problem

During a recent security review, the InfoSec team raised concerns:

> "We don't have visibility into how the raw data landing zone was configured. We need to ensure it meets our security standards before any more sensitive data flows through it. Also, we need a repeatable, auditable way to deploy infrastructure - not just manual clicking."

Your task is to investigate what Sam built, identify security vulnerabilities, and rebuild it properly using secure Infrastructure as Code principles.

## 🎯 Your Mission

Over the course of this workshop, you'll:

1. **Audit** the legacy architecture (Activity 1)
2. **Simulate** inheriting the problem by deploying Sam's insecure setup (Activity 2)
3. **Introspect** what was actually deployed using Azure CLI (Activity 3)
4. **Refactor** to a secure baseline template (Activity 4)
5. **Sketch** a proper secure data flow architecture (Activity 5)
6. **Parameterise** the template for reuse across environments (Activity 6)
7. **Validate** changes using `what-if` before deploying (Activity 7)
8. **Deploy** the secure infrastructure (Activity 8)
9. **Document** governance handoff for the operations team (Activity 9)
10. **Reflect** on industry security standards and frameworks (Activity 10)

## 🚗 Two Ways to Fix This

You'll learn that there are **two approaches** to fixing inherited insecure infrastructure:

### Lane 1: Quick Patch (Emergency Fix)

Export the existing configuration as JSON, patch the bad bits, and redeploy. This is **fast** but:
- ❌ Brittle (full of read-only metadata noise)
- ❌ Not repeatable across environments
- ❌ Hard to review and audit

**When to use:** Production is down, emergency fix needed, then fix properly later.

### Lane 2: Refactor to Standard (Enterprise Way)

Build a clean, secure baseline template from scratch. This is **sustainable** because:
- ✅ Repeatable across dev → test → live
- ✅ Reviewable by security teams
- ✅ Standards-based (CIS, NIST, PCI-DSS)

**When to use:** Always (default approach).

**This workshop teaches Lane 2** - the professional, standards-based approach. But you'll learn why Lane 1 exists and when it might be acceptable.

## 🔐 What You'll Discover

As you work through the activities, you'll uncover security vulnerabilities in Sam's setup:

- 🔓 **Public blob access enabled** - Anyone with the URL can read files
- 🔑 **Hardcoded SAS tokens** - "God mode" credentials with far-future expiry (2099!)
- 🔒 **Weak TLS enforcement** - TLS 1.0 (deprecated, vulnerable to attacks)
- 📋 **No audit logging** - Can't track who accessed what
- 🏷️ **No governance tags** - Can't identify owner, environment, or cost centre
- 🎫 **No identity-based access control** - Using shared secrets instead of Azure AD/RBAC

## 🎓 Real-World Context

This scenario mirrors real-world situations you might encounter:

- **Inheriting brownfield systems** without documentation
- **Balancing speed vs. sustainability** (quick fix vs. proper refactor)
- **Meeting security standards** for live system promotion
- **Communicating with governance teams** (InfoSec, Platform, Operations)

The skills you learn today directly apply to your EPA project and professional practice.

---

**Ready to investigate?** Start with [Activity 1: Legacy Audit](activities/activity-1/activity-1_start.md) and examine the flawed architecture diagram.
