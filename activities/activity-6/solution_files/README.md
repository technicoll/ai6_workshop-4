# Activity 6 Solution Files

This folder contains the completed parameterized template from Activity 6.

## main_secure_parameterized.bicep

This is the secure baseline template with parameterization added.

**Key additions from Activity 4:**
- **Parameters:**
  - `env` (dev/test/live/prod) with `@allowed()` decorator
  - `location` (region)
  - `owner` (team name)
- **Environment-aware naming:**
  - Storage account: `safe${env}${uniqueString(...)}`
  - Container: `raw-${env}`
- **Governance tags:**
  - environment
  - owner
  - costCentre
  - managedBy
- **Outputs:**
  - storageAccountName
  - containerName
  - environment

**Important:** Security properties are NOT parameterized:
- `allowBlobPublicAccess: false` (hardcoded)
- `minimumTlsVersion: 'TLS1_2'` (hardcoded)
- `publicAccess: 'None'` (hardcoded)

This template can be deployed to multiple environments with different names but identical security posture.

Use this to verify your parameterization or as a reference if you get stuck.
