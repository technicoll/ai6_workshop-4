#!/bin/bash
# APPROACH 2: Simple Two-Command Version
# This version uses direct commands for easier understanding

echo "=== LEGACY STORAGE (INSECURE) ==="
az storage account show \
  --name legacykfq7ojdu5awo4 \
  --resource-group $rg \
  --query "{TLS:minimumTlsVersion, PublicAccess:allowBlobPublicAccess}" \
  --output table

echo ""
echo "=== SECURE STORAGE (FIXED) ==="
az storage account show \
  --name safedevkfq7ojdu5awo4 \
  --resource-group $rg \
  --query "{TLS:minimumTlsVersion, PublicAccess:allowBlobPublicAccess}" \
  --output table

# NOTE: Replace the storage account names with your actual names
# You can find them with: az storage account list -g $rg -o table
