#!/bin/bash
# Activity 11 CLI Test Script
# This script tests all CLI commands from Activity 11
#
# Usage:
#   ./test-activity-11-cli.sh              # Auto-deploy everything (default)
#   ./test-activity-11-cli.sh --interactive # Prompt before each action
#   ./test-activity-11-cli.sh --dry-run    # Check only, don't deploy

set -e  # Exit on error

# Parse command line arguments
INTERACTIVE=false
DRY_RUN=false

for arg in "$@"; do
    case $arg in
        --interactive|-i)
            INTERACTIVE=true
            shift
            ;;
        --dry-run|-d)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --interactive, -i    Prompt before each deployment action"
            echo "  --dry-run, -d        Check resources but don't deploy anything"
            echo "  --help, -h           Show this help message"
            echo ""
            echo "Default: Auto-deploy everything (safe for sandboxes)"
            exit 0
            ;;
    esac
done

echo "========================================="
echo "Activity 11 CLI Test Script"
echo "========================================="
if [ "$DRY_RUN" = true ]; then
    echo "🔍 DRY RUN MODE - No deployments will be made"
elif [ "$INTERACTIVE" = true ]; then
    echo "💬 INTERACTIVE MODE - Will prompt before actions"
else
    echo "🚀 AUTO MODE - Will deploy automatically"
fi
echo ""

# Part 0: Pre-Flight Check
echo "=== Part 0: Pre-Flight Check ==="
echo ""

echo "Step 0.1: Verify Azure Access"
export rg=$(az group list --query "[0].name" -o tsv)
echo "✅ Resource Group: $rg"

export LOCATION=$(az group show --name $rg --query location -o tsv)
echo "✅ Location: $LOCATION"
echo ""

echo "Step 0.2: Check for Existing Secure Storage"
WHAT_IF_OUTPUT=$(az deployment group what-if \
  --resource-group $rg \
  --template-file templates/main_secure_complete.bicep \
  --parameters env=dev location=$LOCATION \
  --no-pretty-print 2>&1)

echo "$WHAT_IF_OUTPUT"
echo ""

# Check if storage needs to be created (look for "Create" changes)
NEEDS_DEPLOYMENT=$(echo "$WHAT_IF_OUTPUT" | grep -c '"changeType": "Create"' || echo "0")

if [ "$NEEDS_DEPLOYMENT" -eq "0" ]; then
    echo "ℹ️  Storage already exists (no Create changes detected)"
    STORAGE_EXISTS=true
else
    echo "ℹ️  Storage needs to be deployed ($NEEDS_DEPLOYMENT resource(s) to create)"
    STORAGE_EXISTS=false
fi
echo ""

echo "Step 0.3: Deploy Secure Storage (if needed)"

if [ "$STORAGE_EXISTS" = true ]; then
    echo "⏭️  Skipping deployment - storage already exists"
elif [ "$DRY_RUN" = true ]; then
    echo "🔍 DRY RUN - Skipping deployment"
elif [ "$INTERACTIVE" = true ]; then
    read -p "Do you want to deploy the secure storage? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        SHOULD_DEPLOY=true
    else
        SHOULD_DEPLOY=false
    fi
else
    echo "🚀 Auto-deploying secure storage..."
    SHOULD_DEPLOY=true
fi

if [ "$SHOULD_DEPLOY" = true ]; then
    az deployment group create \
      --resource-group $rg \
      --template-file templates/main_secure_complete.bicep \
      --parameters env=dev location=$LOCATION \
      --name secure-storage-dev
    echo "✅ Deployment complete"
else
    echo "⏭️  Skipping deployment"
fi
echo ""

echo "Step 0.4: Capture Storage Details"
export STORAGE_ACCOUNT=$(az deployment group show \
  --resource-group $rg \
  --name secure-storage-dev \
  --query 'properties.outputs.storageAccountName.value' -o tsv 2>/dev/null || echo "NOT_DEPLOYED")

export CONTAINER_NAME=$(az deployment group show \
  --resource-group $rg \
  --name secure-storage-dev \
  --query 'properties.outputs.containerName.value' -o tsv 2>/dev/null || echo "NOT_DEPLOYED")

export SUBSCRIPTION_ID=$(az account show --query id -o tsv)

echo "✅ Storage Account: $STORAGE_ACCOUNT"
echo "✅ Container Name: $CONTAINER_NAME"
echo "✅ Subscription ID: $SUBSCRIPTION_ID"
echo ""

# Part 1: ML Workspace (CLI approach)
echo "=== Part 1: ML Workspace (CLI Deployment) ==="
echo ""

# Check if ML extension is installed
echo "Checking Azure ML CLI extension..."
ML_EXTENSION=$(az extension list --query "[?name=='ml'].version" -o tsv 2>/dev/null || echo "")

if [ -z "$ML_EXTENSION" ]; then
    echo "⚠️  Azure ML extension not installed"
    
    SHOULD_INSTALL=true
    if [ "$DRY_RUN" = true ]; then
        echo "🔍 DRY RUN - Skipping installation"
        SHOULD_INSTALL=false
        SKIP_WORKSPACE=true
    elif [ "$INTERACTIVE" = true ]; then
        read -p "Install Azure ML extension? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            SHOULD_INSTALL=false
            SKIP_WORKSPACE=true
        fi
    else
        echo "🚀 Auto-installing ML extension..."
    fi
    
    if [ "$SHOULD_INSTALL" = true ]; then
        az extension add --name ml --yes
        echo "✅ ML extension installed"
    else
        echo "⏭️  Skipping ML extension installation and workspace creation"
    fi
else
    echo "✅ ML extension installed (version $ML_EXTENSION)"
fi
echo ""

if [ "$SKIP_WORKSPACE" != "true" ] && [ "$STORAGE_ACCOUNT" != "NOT_DEPLOYED" ]; then
    # Check if workspace exists
    echo "Checking for ML workspace 'mlw-workshop'..."
    
    # Use a simpler list command with timeout
    WORKSPACE_EXISTS=$(timeout 30s az ml workspace list --resource-group $rg --query "[?name=='mlw-workshop'].name" -o tsv 2>/dev/null || echo "")

    if [ ! -z "$WORKSPACE_EXISTS" ]; then
        echo "✅ Workspace 'mlw-workshop' already exists"
        echo "   Skipping creation..."
    else
        echo "⚠️  Workspace 'mlw-workshop' does not exist"
        
        SHOULD_CREATE=true
        if [ "$DRY_RUN" = true ]; then
            echo "🔍 DRY RUN - Skipping workspace creation"
            SHOULD_CREATE=false
        elif [ "$INTERACTIVE" = true ]; then
            read -p "Create ML workspace using CLI? (y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                SHOULD_CREATE=false
            fi
        else
            echo "🚀 Auto-creating ML workspace..."
        fi
        
        if [ "$SHOULD_CREATE" = true ]; then
            echo "Creating ML workspace with secure storage..."
            
            # Get storage account resource ID
            STORAGE_RESOURCE_ID="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$rg/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT"
            
            # Create workspace using CLI
            az ml workspace create \
              --name mlw-workshop \
              --resource-group $rg \
              --location $LOCATION \
              --storage-account "$STORAGE_RESOURCE_ID" \
              --display-name "Secure ML Workshop" \
              --description "ML workspace using secure landing zone storage from Workshop Activities 1-10" \
              --tags environment=workshop purpose=activity-11-ml-pipeline createdBy=test-script
            
            if [ $? -eq 0 ]; then
                echo "✅ ML workspace created successfully"
            else
                echo "❌ Failed to create ML workspace"
                echo "   You can create it manually via Portal (Activity 11, Part 1)"
            fi
        else
            echo "⏭️  Skipping ML workspace creation"
            echo "   You can create it manually via Portal (Activity 11, Part 1)"
        fi
    fi
else
    echo "⚠️  Storage not available or ML extension not installed"
    echo "   Skipping ML workspace creation"
    echo "   You can create it manually via Portal (Activity 11, Part 1)"
fi
echo ""

# Verify workspace connection
if [ "$SKIP_WORKSPACE" != "true" ]; then
    echo "Verifying workspace connection to storage..."
    
    # Use list command instead of show to avoid hanging
    WORKSPACE_CHECK=$(timeout 30s az ml workspace list --resource-group $rg --query "[?name=='mlw-workshop'].{name:name,location:location}" -o json 2>/dev/null || echo "[]")
    
    if [ "$WORKSPACE_CHECK" != "[]" ] && [ ! -z "$WORKSPACE_CHECK" ]; then
        echo "✅ Workspace found and accessible"
        echo "$WORKSPACE_CHECK"
    else
        echo "ℹ️  Workspace status unknown - continue with Portal if needed"
    fi
fi
echo ""

# Part 2: Data Preparation
echo "=== Part 2: Data Preparation ==="
echo ""

echo "Step 2.1: Download Taxi Data"
if [ -f "taxi-data.csv" ]; then
    echo "✅ taxi-data.csv already exists"
else
    curl -o taxi-data.csv https://raw.githubusercontent.com/Azure/mlops-v2-ado-demo/refs/heads/main/data/taxi-data.csv
    echo "✅ Downloaded taxi-data.csv"
fi
ls -lh taxi-data.csv
echo ""

echo "Step 2.2: Get ML Workspace Default Datastore Container"
# The ML workspace creates a default container in our secure storage
# We need to upload there for ML Studio to see the data

DEFAULT_CONTAINER=$(timeout 30s az ml datastore show \
  --name workspaceblobstore \
  --resource-group $rg \
  --workspace-name mlw-workshop \
  --query container_name -o tsv 2>/dev/null || echo "")

if [ -z "$DEFAULT_CONTAINER" ]; then
    echo "⚠️  Could not get default datastore container"
    echo "   ML workspace may not exist yet - using raw-workshop as fallback"
    DEFAULT_CONTAINER=$CONTAINER_NAME
else
    echo "✅ Default datastore container: $DEFAULT_CONTAINER"
fi
echo ""

echo "Step 2.3: Upload to ML Workspace Storage"
if [ "$STORAGE_ACCOUNT" != "NOT_DEPLOYED" ]; then
    SHOULD_UPLOAD=true
    if [ "$DRY_RUN" = true ]; then
        echo "🔍 DRY RUN - Skipping upload"
        SHOULD_UPLOAD=false
    elif [ "$INTERACTIVE" = true ]; then
        read -p "Upload taxi-data.csv to storage? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            SHOULD_UPLOAD=false
        fi
    else
        echo "🚀 Auto-uploading data to ML workspace storage..."
    fi
    
    if [ "$SHOULD_UPLOAD" = true ]; then
        az storage blob upload \
          --account-name $STORAGE_ACCOUNT \
          --container-name $DEFAULT_CONTAINER \
          --name taxi-data.csv \
          --file taxi-data.csv \
          --auth-mode login \
          --overwrite
        echo "✅ Upload complete to container: $DEFAULT_CONTAINER"
    else
        echo "⏭️  Skipping upload"
    fi
else
    echo "⚠️  Storage not deployed, skipping upload"
fi
echo ""

echo "Step 2.4: Verify Data Location"
if [ "$STORAGE_ACCOUNT" != "NOT_DEPLOYED" ]; then
    az storage blob list \
      --account-name $STORAGE_ACCOUNT \
      --container-name $DEFAULT_CONTAINER \
      --auth-mode login \
      --query "[].{Name:name, Size:properties.contentLength}" -o table
    
    echo ""
    echo "Blob URL for Data Asset:"
    echo "https://$STORAGE_ACCOUNT.blob.core.windows.net/$DEFAULT_CONTAINER/taxi-data.csv"
    echo ""
    echo "💡 This container is the ML workspace's default datastore (workspaceblobstore)"
    echo "   ML Studio will automatically see files uploaded here!"
else
    echo "⚠️  Storage not deployed, skipping verification"
fi
echo ""

# Part 11: Security Review
echo "=== Part 11: Security Review ==="
echo ""

if [ "$STORAGE_ACCOUNT" != "NOT_DEPLOYED" ]; then
    echo "Step 11.1: Security Assessment"
    echo "Verifying storage security settings..."
    
    az storage account show \
      --name $STORAGE_ACCOUNT \
      --resource-group $rg \
      --query "{name:name, allowBlobPublicAccess:allowBlobPublicAccess, minimumTlsVersion:minimumTlsVersion}" \
      -o table
    
    echo ""
    
    az storage container show \
      --account-name $STORAGE_ACCOUNT \
      --name $CONTAINER_NAME \
      --auth-mode login \
      --query "{name:name, publicAccess:properties.publicAccess}" \
      -o table
    
    echo ""
    echo "✅ Expected values:"
    echo "   - allowBlobPublicAccess: False"
    echo "   - minimumTlsVersion: TLS1_2"
    echo "   - publicAccess: None"
else
    echo "⚠️  Storage not deployed, skipping security verification"
fi
echo ""

echo "========================================="
echo "✅ CLI Test Complete!"
echo "========================================="
echo ""
echo "Summary of environment variables:"
echo "  rg=$rg"
echo "  LOCATION=$LOCATION"
echo "  STORAGE_ACCOUNT=$STORAGE_ACCOUNT"
echo "  CONTAINER_NAME=$CONTAINER_NAME"
echo "  SUBSCRIPTION_ID=$SUBSCRIPTION_ID"
echo ""
echo "Next steps:"
echo "  1. Review outputs above for errors"
echo "  2. Continue with GUI parts of Activity 11"
echo "  3. Create ML workspace via Portal"
echo "  4. Build Designer pipeline"
