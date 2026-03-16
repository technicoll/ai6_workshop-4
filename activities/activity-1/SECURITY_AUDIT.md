# Security Audit: Raw Data Landing Zone

## High-Level Context

Sam, the previous developer, set up the landing zone using ad‑hoc ClickOps and left only a working storage account, a Bash script, and a note saying “It works, don’t touch it.” There is no documentation or Infrastructure as Code, leaving the system fragile and difficult to maintain.

## Vulnerabilities Identified

### Vulnerability 1: [No TLS enforcement]
**Location:** [Front Door]
**Risk:** [Insecure web traffic can be sniffed, also enabled MITM attacks]
**Severity:** [High]

### Vulnerability 2: [Public Blob Access]
**Location:** [Storage Container]
**Risk:** [Unauthenticated public access]
**Severity:** [High]

### Vulnerability 3: [Weak TLS (1.0]
**Location:** [Storage Container/Front Door]
**Risk:** [Susceptible to attack]
**Severity:** [High]

### Vulnerability 4: [Hardcoded SAS Token]
**Location:** [Script]
**Risk:** ["God mode" permissions, comsumer impact]
**Severity:** [High]

## Recommendations
[What should be done to fix these issues]

1. Enforce TLS and HTTPS
2. Disable unauthenticated public storage access
3. Upgrade TLS protocol
4. Remove hard-coded credentials in the script and use a service account or azure secret key vault instead.
