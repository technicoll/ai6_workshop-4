#!/bin/bash
# APPROACH 1: Fixed Script Version
# This version properly handles variable scoping to avoid the error

echo "=== LEGACY STORAGE (INSECURE) ==="
LEGACY_NAME=$(az storage account list -g $rg --query "[?starts_with(name, 'legacy')].name" -o tsv)
az storage account show \
  --name "$LEGACY_NAME" \
  --resource-group $rg \
  --query "{TLS:minimumTlsVersion, PublicAccess:allowBlobPublicAccess}" \
  --output table

echo ""
echo "=== SECURE STORAGE (FIXED) ==="
SECURE_NAME=$(az storage account list -g $rg --query "[?starts_with(name, 'safe')].name" -o tsv)
az storage account show \
  --name "$SECURE_NAME" \
  --resource-group $rg \
  --query "{TLS:minimumTlsVersion, PublicAccess:allowBlobPublicAccess}" \
  --output table
