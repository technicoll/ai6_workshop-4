# Activity 2: Simulating Inherited Problem - SOLUTION

**Primary KSB:** S8 (Assess system vulnerabilities and mitigate the threats or risks to assets, data and cyber security), S16 (setup)

---

## ✅ Quick Check

Your deployment succeeded if:

| Check | Expected |
|-------|----------|
| `az storage account list -g $rg -o table` | Shows `legacy<random>` storage account |
| Container `raw-insecure` exists | `PublicAccess: blob` |
| TLS version | `TLS1_0` |
| `allowBlobPublicAccess` | `True` |

---

## 🔧 Troubleshooting

**"$rg is empty"**  
→ Run: `export rg=$(az group list --query "[0].name" -o tsv)`

**"Deployment failed"**  
→ Check you're in the workshop root (`pwd`) and `legacy.bicep` exists (`ls legacy.bicep`)

**"Storage account not found"**  
→ Wait 1-2 mins and retry - deployment may still be in progress

**"BCP035 warning about missing 'kind' property"**  
→ This is expected! The legacy template is intentionally incomplete. Deployment still succeeds.

---

## 🚀 Extension Solution

```bash
az deployment group show \
  --resource-group $rg \
  --name legacy-deployment \
  --output json > deployment-output.json
```

Look at `properties.dependencies` to see the deployment order:
- Storage Account → Blob Service → Container

---

## 🔗 Next Activity

Move to [Activity 3: Introspection](../activity-3/activity-3_start.md)

