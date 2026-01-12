# Activity 11: Build a Secure ML Pipeline with Your Landing Zone

**🎯 Learning Objectives:**
- Connect Azure ML workspace to secure infrastructure from Activities 1-10
- Use secure storage for ML data (not external URLs)
- Build production-ready ML pipeline with governance principles
- Apply security and IaC principles to ML workloads

**📋 What You'll Build:**

A complete ML pipeline that:
1. **Uses** the secure storage landing zone from Activities 1-10
2. **Loads** taxi trip data from secure blob storage
3. **Prepares** the data (select columns, split train/test)
4. **Trains** a Random Forest Regression model
5. **Evaluates** performance with metrics and visualizations
6. **Registers** the trained model for deployment

**🔗 Connection to Previous Activities:**
This activity brings together everything you've learned about secure infrastructure. Your ML workspace will use the secure storage account you deployed and validated in Activities 1-10.

### Note on MLflow

The original CLI-based pipeline uses **MLflow** for experiment tracking. However, MLflow is **not preinstalled** in Designer's Execute Python Script component.

Instead, we'll use:
- **Print statements** - View metrics in the component's log file
- **`run.upload_file()`** - Upload visualizations to the run outputs
- **Azure ML Run context** - Access workspace and log basic info

For full MLflow support, use Azure ML SDK pipelines* or Notebooks** instead of Designer.

*This requires creation of a new environment that Pluralsight blocks as it detects too much compute.
**Notebooks will work in the Pluralsight sandbox in which you can use the single compute and install MLflow or use the pre-installed mlflow-skinny. This is a further final exercise to explore.

⚠️ **Important - Sandbox Time Limits:**
Pluralsight sandboxes are time-limited. If your sandbox has expired, this activity includes steps to re-authenticate and redeploy the secure infrastructure. The instructions are designed to work independently from previous activities.

---

## Part 0: Pre-Flight Check & Secure Infrastructure Setup

**🎯 Purpose:** Ensure secure storage exists and capture connection details

### Step 0.1: Verify Azure Access

Whether your sandbox is still active or you're starting fresh, let's verify access:

⌨️ **Run:**

```bash
# Re-authenticate if needed (won't hurt if already logged in)
az login

# Set resource group variable
export rg=$(az group list --query "[0].name" -o tsv)
echo "Resource Group: $rg"

# Set location variable
export LOCATION=$(az group show --name $rg --query location -o tsv)
echo "Location: $LOCATION"
```

✅ **Checkpoint:** You see your resource group name and location printed

---

### Step 0.2: Check for Existing Secure Storage

Let's see if the secure storage from Activities 1-10 already exists:

⌨️ **Run:**

```bash
# Check what's currently deployed
az deployment group what-if \
  --resource-group $rg \
  --template-file templates/main_secure_complete.bicep \
  --parameters env=dev location=$LOCATION
```

**If you see:**
- **"No changes"** → Storage already exists, skip to Step 0.3
- **"Create" operations** → Storage doesn't exist, continue to deploy it

---

### Step 0.3: Deploy Secure Storage (if needed)

If the storage doesn't exist, deploy it now:

⌨️ **Run:**

```bash
# Navigate to workshop root (if not already there)
cd /workspaces/ai6_workshop-4

# Deploy the secure storage
az deployment group create \
  --resource-group $rg \
  --template-file templates/main_secure_complete.bicep \
  --parameters env=dev location=$LOCATION \
  --name secure-storage-dev
```

⏱️ **This takes 1-2 minutes**

✅ **Checkpoint:** Deployment succeeds with `"provisioningState": "Succeeded"`

---

### Step 0.4: Capture Storage Details

Now let's get the storage account information we'll need:

⌨️ **Run:**

```bash
# Get storage account name
export STORAGE_ACCOUNT=$(az deployment group show \
  --resource-group $rg \
  --name secure-storage-dev \
  --query 'properties.outputs.storageAccountName.value' -o tsv)

echo "Storage Account: $STORAGE_ACCOUNT"

# Get container name
export CONTAINER_NAME=$(az deployment group show \
  --resource-group $rg \
  --name secure-storage-dev \
  --query 'properties.outputs.containerName.value' -o tsv)

echo "Container Name: $CONTAINER_NAME"

# Get subscription ID (needed for ML workspace config)
export SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Subscription ID: $SUBSCRIPTION_ID"
```

✅ **Checkpoint:** You see all three values printed (storage account, container, subscription)

💡 **Tip:** Keep this terminal open - you'll need these variables in later steps!

---

## Part 1: Create Azure ML Workspace

**🎯 Purpose:** Create an ML workspace that uses your secure storage

### Step 1.1: Create Workspace via Portal (Recommended for Speed)

We'll use the Azure Portal wizard for speed. In production, you'd use Infrastructure as Code (CLI approach shown in Step 1.3).

1. Open [Azure Portal](https://portal.azure.com)
2. Search for **"Machine Learning"** in the top search bar
3. Click **+ Create** → **New workspace**

**Basics tab:**
- **Subscription:** Your Pluralsight sandbox subscription
- **Resource group:** Select your existing resource group (from `$rg`)
- **Workspace name:** `mlw-workshop` (or make it unique)
- **Region:** Same as your resource group
- **Storage account:** Click dropdown → Select your secure storage (starts with `safedev...`)
- **Key vault:** Leave as **Create new**
- **Application insights:** Leave as **Create new**
- **Container registry:** Leave as **None**

4. Click **Review + Create**
5. Click **Create**

⏱️ **This takes 2-3 minutes**

✅ **Checkpoint:** Workspace deployment succeeds

💡 **Why this approach?** In a workshop, we prioritize speed. In production, you'd use the CLI approach (see Step 1.3) for repeatability and version control.

---

### Step 1.2: Verify Workspace Connection

Let's verify the workspace can see your secure storage:

⌨️ **Run:**

```bash
# List ML workspaces in your resource group
az ml workspace show \
  --name mlw-workshop \
  --resource-group $rg \
  --query "{name:name, storageAccount:storageAccount}" -o table
```

✅ **Checkpoint:** You see your workspace name and storage account path

---

### Step 1.3: Alternative - CLI Approach (Optional - Read Only)

For production environments, you'd use a YAML configuration file with the Azure CLI:

📖 **How it works:**

1. Create a `workspace-config.yml` file (already provided in this folder)
2. Update placeholders with your subscription, resource group, and storage account
3. Deploy with:

```bash
az ml workspace create \
  --resource-group $rg \
  --file activities/activity-11-going-further/workspace-config.yml
```

**Benefits:**
- ✅ Repeatable across environments
- ✅ Version controlled in Git
- ✅ Can be parameterized for dev/test/prod
- ✅ Follows IaC principles from Activities 1-10

📖 **Learn more:** [Manage Azure ML workspaces using Azure CLI](https://learn.microsoft.com/en-us/azure/machine-learning/how-to-manage-workspace-cli)

💡 **For this workshop:** We used the Portal for speed. Use the CLI approach for your EPA projects!

---

## Part 2: Prepare Data in Secure Storage

**🎯 Purpose:** Download taxi data and upload to ML workspace storage

When an ML workspace is created, it automatically creates a **default datastore** container in your secure storage account. ML Studio's Data Asset browser uses this default datastore, so we'll upload our data there.

💡 **Key Insight:** The ML workspace uses the secure storage account you deployed in Activities 1-10! The default datastore container (created automatically) still inherits all your security settings (TLS 1.2, no public access).

### Step 2.1: Download Taxi Data Locally

⌨️ **Run:**

```bash
# Download the taxi dataset
curl -o taxi-data.csv https://raw.githubusercontent.com/Azure/mlops-v2-ado-demo/refs/heads/main/data/taxi-data.csv

# Verify download
ls -lh taxi-data.csv
```

✅ **Checkpoint:** You see `taxi-data.csv` file (~800KB)

---

### Step 2.2: Get the ML Workspace Default Container

The ML workspace created a default container for its datastore. Let's find it:

⌨️ **Run:**

```bash
# Get the default datastore container name
export DEFAULT_CONTAINER=$(az ml datastore show \
  --name workspaceblobstore \
  --resource-group $rg \
  --workspace-name mlw-workshop \
  --query container_name -o tsv)

echo "Default container: $DEFAULT_CONTAINER"
```

✅ **Checkpoint:** You see a container name (typically starts with `azureml-blobstore-`)

---

### Step 2.3: Upload to ML Workspace Storage

**Option A: Portal Upload (Recommended for Speed)**

1. Open [Azure Portal](https://portal.azure.com)
2. Navigate to **Resource Groups** → Your resource group
3. Click on your storage account (starts with `safedev...`)
4. In the left menu, click **Containers**
5. Click on the container matching `$DEFAULT_CONTAINER` (from step 2.2)
6. Click **Upload** (top button)
7. Click **Browse for files** → Select `taxi-data.csv`
8. Click **Upload**

✅ **Checkpoint:** File appears in the container with size ~800KB

**Option B: CLI Upload (Alternative)**

⌨️ **Run:**

```bash
# Upload using Azure CLI
az storage blob upload \
  --account-name $STORAGE_ACCOUNT \
  --container-name $DEFAULT_CONTAINER \
  --name taxi-data.csv \
  --file taxi-data.csv \
  --auth-mode login
```

✅ **Checkpoint:** Upload succeeds with `"Finished[#############]  100.0000%"`

💡 **Note:** We use `--auth-mode login` (identity-based) instead of hard-coded keys or SAS tokens. This follows the security principles from Activities 1-10!

---

### Step 2.4: Verify Data Location

⌨️ **Run:**

```bash
# List blobs in default container
az storage blob list \
  --account-name $STORAGE_ACCOUNT \
  --container-name $DEFAULT_CONTAINER \
  --auth-mode login \
  --query "[].{Name:name, Size:properties.contentLength}" -o table
```

✅ **Checkpoint:** You see `taxi-data.csv` listed with size

💡 **Why this container?** ML Studio's default datastore (`workspaceblobstore`) points to this container. When you create a Data Asset, ML Studio will automatically find your uploaded file here.

---

## Part 3: Create the Data Asset

**🎯 Purpose:** Register the taxi data from ML workspace storage as a Data Asset

Now we'll register the uploaded file as a Data Asset so Designer can use it.

### Step 3.1: Navigate to Data Assets

1. Open [Azure Machine Learning Studio](https://ml.azure.com)
2. Select your workspace (`mlw-workshop`)
3. In the left menu, click **Data**
4. Click **+ Create**

### Step 3.2: Configure the Data Asset

1. **Name:** `taxi-data-secure`
2. **Type:** Select **File (uri_file)**
3. Click **Next**

### Step 3.3: Choose Data Source

1. Select **From Azure storage**
2. Click **Next**
3. **Datastore:** Select **workspaceblobstore** (this is the default datastore)
4. Click **Browse**
5. You should see `taxi-data.csv` in the root of the container
6. Select `taxi-data.csv`
7. Click **Next**
8. Review the preview - you should see columns like `cost`, `distance`, `passengers`, etc.
9. Click **Create**

✅ **Checkpoint:** Data asset `taxi-data-secure` is created

💡 **Security Note:** The data asset uses **Azure AD authentication** to access the blob. No SAS tokens or hard-coded keys - just like the secure principles from Activities 1-10!

💡 **Why this works:** Because we uploaded to the ML workspace's default datastore container, ML Studio automatically sees our file when browsing `workspaceblobstore`.

---

## Part 4: Create a Compute Instance

**🎯 Purpose:** Create compute resources to run the Designer pipeline

Designer pipelines need compute to run. We'll create a compute instance.

### Step 4.1: Navigate to Compute

1. In the left menu, click **Compute**
2. Select the **Compute instances** tab
3. Click **+ New**

### Step 4.2: Configure the Compute Instance

1. **Compute name:** `designer-compute` (or any unique name)
2. **Virtual machine type:** CPU
3. **Virtual machine size:** Select `Standard_DS2_v2` (2 cores, 7 GB RAM)
   - This is sufficient for training on small datasets
4. Click **Create**

Wait 2-3 minutes for the compute instance to start (status changes to **Running**).

✅ **Checkpoint:** Compute status shows **Running**

💡 **Cost Note:** 
- **In Pluralsight Sandbox:** No cost concerns - resources are time-limited, not cost-limited
- **In Your Company Environment:** Be conscious of compute costs! Always **Stop** compute instances when not in use, and **Delete** them when finished with the project

---

## Part 5: Create a New Designer Pipeline

### Step 5.1: Open Designer

1. In the left menu, click **Designer**
2. Click **+ New pipeline**
3. At the top, rename the pipeline from "Pipeline-Created-on..." to `taxi-fare-prediction-secure`

### Step 5.2: Set the Default Compute

1. Click the **Settings** gear icon (top right)
2. Under **Default compute target**, select your compute instance (`designer-compute`)
3. Click **Save**

---

## Part 6: Build the Pipeline

Now we'll add components by dragging them from the left panel onto the canvas.

### Step 6.1: Add the Data

1. In the left panel, expand **Data**
2. Find `taxi-data-secure` (the data asset you created from secure storage)
3. Drag it onto the canvas

### Step 6.2: Select Columns

We need to select only the columns used for training.

1. In the left panel, search for **Select Columns in Dataset**
2. Drag it onto the canvas below the data
3. Connect: Drag from the output port of `taxi-data` to the input port of **Select Columns**
4. Click on **Select Columns in Dataset** to select it
5. In the right panel, click **Edit column**
6. Select **By name** and add all 21 columns:

   ```
   cost, distance, dropoff_latitude, dropoff_longitude, passengers,
   pickup_latitude, pickup_longitude, pickup_weekday, pickup_month,
   pickup_monthday, pickup_hour, pickup_minute, pickup_second,
   dropoff_weekday, dropoff_month, dropoff_monthday, dropoff_hour,
   dropoff_minute, dropoff_second, store_forward, vendor
   ```

7. Click **Save**

### Step 6.3: Split the Data

1. Search for **Split Data** and drag it below Select Columns
2. Connect the output of **Select Columns** to the input of **Split Data**
3. Click on **Split Data** and configure:
   - **Splitting mode:** Split Rows
   - **Fraction of rows in the first output:** `0.7` (70% for training)
   - **Randomized split:** Yes
   - **Random seed:** `42` (for reproducibility)

**Split Data** has two outputs:
- **Results dataset1** (left) → Training data (70%)
- **Results dataset2** (right) → Test data (30%)

### Step 6.4: Create the Custom Python Model

We'll use **Create Python Model** to define a Random Forest Regressor.

1. Search for **Create Python Model** and drag it onto the canvas
2. Click on it and paste this code in the **Python script** box:

```python
# Custom Random Forest Regression Model for Taxi Fare Prediction
# Note: MLflow is NOT available in Create Python Model - use Execute Python Script for logging
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import r2_score, mean_squared_error, mean_absolute_error


class AzureMLModel:
    def __init__(self):
        # Hyperparameters (matching original mlops-v2 pipeline)
        self.n_estimators = 500
        self.max_depth = 10
        self.bootstrap = True
        self.max_features = 'auto'
        self.min_samples_leaf = 4
        self.min_samples_split = 5
        
        # RandomForestRegressor with optimized hyperparameters
        self.model = RandomForestRegressor(
            n_estimators=self.n_estimators,
            max_depth=self.max_depth,
            bootstrap=self.bootstrap,
            max_features=self.max_features,
            min_samples_leaf=self.min_samples_leaf,
            min_samples_split=self.min_samples_split,
            random_state=42
        )
        self.feature_column_names = list()

    def train(self, df_train, df_label):
        """Train the model on the provided data."""
        self.feature_column_names = df_train.columns.tolist()
        
        # Train the model
        self.model.fit(df_train, df_label)
        
        # Calculate and print training metrics
        yhat = self.model.predict(df_train)
        r2 = r2_score(df_label, yhat)
        mse = mean_squared_error(df_label, yhat)
        rmse = np.sqrt(mse)
        mae = mean_absolute_error(df_label, yhat)
        
        print(f"Training R²: {r2:.4f}")
        print(f"Training RMSE: ${rmse:.2f}")
        print(f"Training MAE: ${mae:.2f}")

    def predict(self, df):
        """Make predictions using the trained model."""
        predictions = self.model.predict(df[self.feature_column_names])
        return pd.DataFrame({'Scored Labels': predictions})
```

### Step 6.5: Train the Model

1. Search for **Train Model** and drag it onto the canvas
2. Connect:
   - **Create Python Model** output → **Train Model** left input (Untrained model)
   - **Split Data** left output (Results dataset1) → **Train Model** right input (Dataset)
3. Click on **Train Model** and configure:
   - **Label column:** Click **Edit column** → Select `cost` → **Save**

### Step 6.6: Score the Model

1. Search for **Score Model** and drag it onto the canvas
2. Connect:
   - **Train Model** output (Trained model) → **Score Model** left input
   - **Split Data** right output (Results dataset2) → **Score Model** right input

**Score Model** applies the trained model to the test data and adds a `Scored Labels` column with predictions.

### Step 6.7: Evaluate the Model (Custom Python Script)

> **Why not use the built-in Evaluate Model?**  
> The standard **Evaluate Model** component doesn't support custom Python models. It will fail with: *"Evaluating scores produced by Custom Model is currently unsupported."*  
> Instead, we'll use **Execute Python Script** to calculate metrics and create visualizations.

1. Search for **Execute Python Script** and drag it onto the canvas
2. Connect the output of **Score Model** to the **Dataset1** input (left)
3. Click on **Execute Python Script** and replace the code with:

```python
# Evaluate Model with Metrics and Visualizations
import pandas as pd
import numpy as np
from sklearn.metrics import r2_score, mean_absolute_error, mean_squared_error
from matplotlib import pyplot as plt
from azureml.core import Run

def azureml_main(dataframe1=None, dataframe2=None):
    """
    Evaluate the regression model on scored test data.
    
    Input:  dataframe1 = Scored dataset (contains 'cost' and 'Scored Labels')
    Output: dataframe1 = Data with predictions and errors
            dataframe2 = Evaluation metrics
    """
    
    # Extract actual and predicted values
    y_true = dataframe1['cost']
    y_pred = dataframe1['Scored Labels']
    
    # Calculate regression metrics
    r2 = r2_score(y_true, y_pred)
    mse = mean_squared_error(y_true, y_pred)
    rmse = np.sqrt(mse)
    mae = mean_absolute_error(y_true, y_pred)
    
    # Print metrics to log (view in Outputs + logs > 70_driver_log.txt)
    print("=" * 60)
    print("MODEL EVALUATION METRICS (Test Set)")
    print("=" * 60)
    print(f"R² Score:                  {r2:.4f}")
    print(f"Mean Squared Error:        ${mse:.2f}")
    print(f"Root Mean Squared Error:   ${rmse:.2f}")
    print(f"Mean Absolute Error:       ${mae:.2f}")
    print("=" * 60)
    
    # ===== Create Visualizations =====
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Plot 1: Actual vs Predicted scatter plot
    axes[0].scatter(y_true, y_pred, alpha=0.5, edgecolors='k', linewidth=0.5)
    axes[0].plot([y_true.min(), y_true.max()], [y_true.min(), y_true.max()], 
                 'r--', linewidth=2, label='Perfect prediction')
    axes[0].set_xlabel('Actual Fare ($)', fontsize=12)
    axes[0].set_ylabel('Predicted Fare ($)', fontsize=12)
    axes[0].set_title(f'Actual vs Predicted Taxi Fare (R² = {r2:.4f})', fontsize=14)
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    
    # Plot 2: Residuals (prediction errors) distribution
    residuals = y_true - y_pred
    axes[1].hist(residuals, bins=50, edgecolor='black', alpha=0.7, color='steelblue')
    axes[1].axvline(x=0, color='red', linestyle='--', linewidth=2, label='Zero error')
    axes[1].set_xlabel('Prediction Error ($)', fontsize=12)
    axes[1].set_ylabel('Frequency', fontsize=12)
    axes[1].set_title(f'Prediction Error Distribution (MAE = ${mae:.2f})', fontsize=14)
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    img_file = "predictions.png"
    plt.savefig(img_file, dpi=150, bbox_inches='tight')
    
    # Upload plot to run outputs (view in Outputs + logs > graphics/)
    run = Run.get_context(allow_offline=True)
    run.upload_file(f"graphics/{img_file}", img_file)
    print(f"Plot saved to outputs: graphics/{img_file}")
    
    # Create metrics DataFrame for output
    metrics_df = pd.DataFrame({
        'Metric': ['R2_Score', 'MSE', 'RMSE', 'MAE'],
        'Value': [round(r2, 4), round(mse, 2), round(rmse, 2), round(mae, 2)]
    })
    
    # Add error columns to data for analysis
    dataframe1['predicted_fare'] = y_pred
    dataframe1['prediction_error'] = residuals
    dataframe1['absolute_error'] = abs(residuals)
    
    return dataframe1, metrics_df
    return dataframe1, metrics_df
```

### Step 6.8: Register the Model

Finally, we'll register the trained model so it can be used for deployment.

1. Search for **Execute Python Script** and drag another one onto the canvas
2. Connect:
   - **Train Model** output → **Dataset1** input (left)
   - **Evaluate (Execute Python Script)** Result Dataset2 output → **Dataset2** input (right)
3. Replace the code with:

```python
# Log Final Model Summary
import pandas as pd

def azureml_main(dataframe1=None, dataframe2=None):
    """
    Log final model summary information.
    
    Input:  dataframe1 = From Train Model (not directly usable as data)
            dataframe2 = Metrics (from Evaluate step)
    Output: dataframe1 = Summary info
            dataframe2 = Pass-through metrics
    """
    
    # Get metrics for summary
    metrics_info = "N/A"
    if dataframe2 is not None:
        r2 = dataframe2[dataframe2['Metric'] == 'R2_Score']['Value'].values[0]
        rmse = dataframe2[dataframe2['Metric'] == 'RMSE']['Value'].values[0]
        mae = dataframe2[dataframe2['Metric'] == 'MAE']['Value'].values[0]
        metrics_info = f"R²={r2}, RMSE=${rmse}, MAE=${mae}"
    
    # Print summary (view in Outputs + logs > 70_driver_log.txt)
    print("=" * 60)
    print("MODEL TRAINING COMPLETE")
    print("=" * 60)
    print(f"Algorithm: RandomForestRegressor")
    print(f"")
    print(f"Hyperparameters:")
    print(f"  - n_estimators: 500")
    print(f"  - max_depth: 10")
    print(f"  - bootstrap: True")
    print(f"  - min_samples_leaf: 4")
    print(f"  - min_samples_split: 5")
    print(f"  - random_state: 42")
    print(f"")
    print(f"Test Set Metrics: {metrics_info}")
    print("=" * 60)
    print("")
    print("To deploy this model:")
    print("  1. Right-click Train Model component")
    print("  2. Select 'Register model'")
    print("  3. Follow the deployment wizard")
    print("=" * 60)
    
    # Create summary DataFrame
    summary_df = pd.DataFrame({
        'Property': ['Status', 'Algorithm', 'n_estimators', 'max_depth', 'Test Metrics'],
        'Value': ['Complete', 'RandomForestRegressor', '500', '10', metrics_info]
    })
    
    return summary_df, dataframe2
```

> **Tip:** To register the trained model, right-click the **Train Model** component after the pipeline completes and select **Register model**.

---

## Part 7: Your Complete Pipeline

Your pipeline should now look like this:

```
┌─────────────────────────┐
│  taxi-data-secure       │  (Data Asset from secure storage)
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│ Select Columns in       │  (21 columns)
│     Dataset             │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│    Split Data           │  (70% / 30%)
└────┬──────────┬─────────┘
     │          │
   train       test
     │          │
     │          │
┌────┴────┐     │
│ Create  │     │
│ Python  │     │
│ Model   │     │
└────┬────┘     │
     │          │
     ▼          │
┌─────────────────────────┐
│   Train Model           │  (Label: cost)
└──────────┬──────────────┘
           │
     trained model─────────────────┐
           │                       │
           ▼                       │
┌─────────────────────────┐       │
│   Score Model           │←─test─┤
└──────────┬──────────────┘       │
           │                      │
           ▼                      │
┌─────────────────────────┐       │
│ Execute Python          │       │
│ Script (EVALUATE)       │       │
└────┬──────────┬─────────┘       │
     │       metrics              │
     │          │                 │
     │          ▼                 ▼
     │   ┌───────────────────────────────┐
     │   │   Execute Python Script       │
     │   │      (REGISTER MODEL)         │
     │   └───────────────────────────────┘
     │
     ▼
  predictions
  with errors
```

🔗 **Connection to Activities 1-10:** Notice that your data flows through the secure storage landing zone you built and validated in earlier activities. This demonstrates production-ready ML infrastructure!

---

## Part 8: Run the Pipeline

### Step 8.1: Submit the Pipeline

1. Click **Submit** (top right)
2. In the dialog:
   - **Experiment:** Select **Create new**
   - **New experiment name:** `taxi-fare-designer`
   - Click **Submit**

### Step 8.2: Monitor Progress

1. A notification appears - click **View run** (or go to **Jobs** in the left menu)
2. Watch each component turn from gray → blue (running) → green (completed)
3. The pipeline takes approximately 5-10 minutes to complete

### Step 8.3: View Results

Once the pipeline completes:

**View Evaluation Metrics:**
1. Click on the **Evaluate (Execute Python Script)** component
2. In the right panel, click **Outputs + logs**
3. Click **70_driver_log.txt** to see the printed metrics:
   ```
   ============================================================
   MODEL EVALUATION METRICS (Test Set)
   ============================================================
   R² Score:                  0.9234
   Mean Squared Error:        $6.65
   Root Mean Squared Error:   $2.58
   Mean Absolute Error:       $1.72
   ============================================================
   ```

**View Visualizations:**
1. Still in **Outputs + logs**, expand the **graphics/** folder
2. Click on `predictions.png` to see:
   - Actual vs Predicted scatter plot
   - Residuals distribution histogram

**View Training Metrics:**
1. Click on the **Train Model** component
2. In the right panel, click **Outputs + logs**
3. Click **70_driver_log.txt** to see training R², RMSE, MAE

**View Scored Data:**
1. Click on **Score Model** component
2. In the right panel, click **Outputs + logs** → **Preview data**
3. You'll see the test data with a `Scored Labels` column containing predictions

**View Model Summary:**
1. Click on the final **Execute Python Script** (Summary) component
2. Check **Outputs + logs** → **70_driver_log.txt** for full summary

---

## Part 9: Understanding the Results

### What the Metrics Mean

| Metric | Meaning | Good Value |
|--------|---------|------------|
| **R² Score** | How much variance the model explains (0-1) | > 0.8 |
| **RMSE** | Average error in dollars | Lower is better |
| **MAE** | Average absolute error in dollars | Lower is better |

### Interpreting the Plots

**Actual vs Predicted Plot:**
- Points close to the red dashed line = accurate predictions
- Spread around the line = prediction uncertainty
- Clusters far from the line = systematic errors

**Residuals Distribution:**
- Centered at 0 = unbiased predictions
- Symmetric shape = consistent errors
- Wide spread = high variance in predictions

---

## Part 10: Cleanup

To avoid ongoing charges:

1. **Stop the compute instance:**
   - Go to **Compute** → **Compute instances**
   - Select your instance → Click **Stop**

2. **Delete resources (optional):**
   - Delete the compute instance if no longer needed
   - Delete the experiment runs from **Jobs**

💡 **Cost Reminder:**
- **In Pluralsight Sandbox:** Resources are time-limited, so cleanup is less critical
- **In Your Company Environment:** Always stop/delete compute instances when not in use to control costs

---

## Part 11: Security Review & Learn More

**🎯 Purpose:** Verify your security settings and explore Azure ML security documentation

### Step 11.1: Verify Storage Security

Let's confirm the storage account maintains the security settings from Activities 1-10:

⌨️ **Run:**

```bash
# Verify storage security settings
az storage account show \
  --name $STORAGE_ACCOUNT \
  --resource-group $rg \
  --query "{name:name, allowBlobPublicAccess:allowBlobPublicAccess, minimumTlsVersion:minimumTlsVersion}" \
  -o table
```

✅ **Checkpoint:** 
- `allowBlobPublicAccess` = `False`
- `minimumTlsVersion` = `TLS1_2`

---

### Step 11.2: Learn More - Azure ML Security Documentation

Microsoft provides comprehensive documentation on securing Azure ML workspaces. Explore these resources to understand enterprise-grade ML security:

📖 **Essential Reading:**

| Topic | Link | What You'll Learn |
|-------|------|-------------------|
| **Enterprise Security Overview** | [concept-enterprise-security](https://learn.microsoft.com/en-us/azure/machine-learning/concept-enterprise-security) | Authentication, authorization, network security, data encryption |
| **Secure Workspace Tutorial** | [tutorial-create-secure-workspace](https://learn.microsoft.com/en-us/azure/machine-learning/tutorial-create-secure-workspace) | VNets, private endpoints, managed virtual networks |
| **Identity-Based Data Access** | [how-to-identity-based-service-authentication](https://learn.microsoft.com/en-us/azure/machine-learning/how-to-identity-based-service-authentication) | Why `--auth-mode login` is better than SAS tokens |
| **Responsible AI** | [concept-responsible-ai](https://learn.microsoft.com/en-us/azure/machine-learning/concept-responsible-ai) | Fairness, reliability, privacy, transparency, accountability |

💡 **Key Takeaway:** In this workshop, you used **identity-based authentication** (`--auth-mode login`) to upload data. The Azure ML docs explain why this is more secure than SAS tokens or access keys - it's auditable, uses short-lived tokens, and follows least-privilege principles.

---

### Step 11.3: Update Handoff Documentation

If you completed Activity 9, add these notes to your handoff document:

📝 **Add to `HANDOFF.md`:**

```markdown
## Machine Learning Infrastructure (Dev/Test Only)

⚠️ **Note:** This ML workspace was created via Portal for workshop purposes. 
For production, deploy using Infrastructure as Code - see docs below.

- **Workspace:** mlw-workshop (dev/test only - not IaC deployed)
- **Storage:** Uses secure storage from Activities 1-10 (safedev...)
- **Data Access:** Identity-based authentication (no SAS tokens)
- **Compute:** Stop instances when not in use to control costs

### Production Requirements
Before promoting to production, consult:
- [Enterprise Security](https://learn.microsoft.com/en-us/azure/machine-learning/concept-enterprise-security) - Network isolation, private endpoints
- [Secure Workspace Tutorial](https://learn.microsoft.com/en-us/azure/machine-learning/tutorial-create-secure-workspace) - IaC deployment with VNets
- [CLI Workspace Management](https://learn.microsoft.com/en-us/azure/machine-learning/how-to-manage-workspace-cli) - YAML-based deployment
```

---

## Summary

Congratulations! You've successfully built a complete, secure ML pipeline that:

✅ **Connected** to the secure storage landing zone from Activities 1-10  
✅ **Used** identity-based authentication (not SAS tokens or keys)  
✅ **Loaded** data from secure blob storage (not external URLs)  
✅ **Trained** a custom Random Forest model using Python  
✅ **Evaluated** performance with metrics and visualizations  

### Key Learnings

1. **Infrastructure Integration:** ML workspaces can use existing secure storage
2. **Identity-Based Access:** `--auth-mode login` eliminates hard-coded secrets
3. **Create Python Model** lets you use scikit-learn algorithms
4. **Execute Python Script** enables matplotlib visualizations
5. View metrics in **Outputs + logs → 70_driver_log.txt**

### Connections to Workshop Activities 1-10

| Activity | Connection to Activity 11 |
|----------|---------------------------|
| **4** | Secure baseline template → Storage used by ML workspace |
| **6** | Parameterization → Could apply to ML workspace deployment |
| **9** | Handoff documentation → Updated with ML infrastructure |

---

## Next Steps

🚀 **Extend Your Learning:**

1. **Deploy the model** as a real-time endpoint
2. **Add network isolation** with private endpoints (see [secure workspace tutorial](https://learn.microsoft.com/en-us/azure/machine-learning/tutorial-create-secure-workspace))
3. **Explore Responsible AI** dashboard for model fairness

---

## � Going Further: Apply to Your EPA Project

**Finished early and want more?** Here are two practical exercises to apply what you've learned to your own EPA project.

### Option 1: Build a Pipeline with Your Own Data

Create a Designer pipeline using data relevant to your EPA project:

1. **Find or create a dataset:**
   - Use a **public dataset** from [Kaggle](https://www.kaggle.com/datasets), [UCI ML Repository](https://archive.ics.uci.edu/), or [Azure Open Datasets](https://learn.microsoft.com/en-us/azure/open-datasets/)
   - Generate **synthetic data** that mimics your EPA project's structure (use Python's `faker` or `sklearn.datasets`)
   - ⚠️ **Never use real company data** in a sandbox environment

2. **Upload to your secure storage** (same process as Part 2)

3. **Build a pipeline** tailored to your problem:
   - Classification? Use `Create Python Model` with `RandomForestClassifier`
   - Time series? Explore the built-in forecasting components
   - Different features? Modify the column selection

4. **Document your approach** - this could become part of your EPA evidence!

---

### Option 2: Create an Azure ML Notebook (MLflow Enabled)

Notebooks give you **full MLflow support** for experiment tracking - something Designer doesn't offer.

**Why this matters for your EPA:**
- Track experiments across multiple runs
- Compare model versions with metrics and parameters
- Build toward an MVP with proper experiment management

**Quick Start:**

1. In Azure ML Studio, go to **Notebooks**
2. Click **+ Create new file** → Name it `epa-experiment.ipynb`
3. Select your existing compute instance (`designer-compute`)

**💡 Get Data Loading Code Automatically:**

Azure ML Studio generates ready-made code for you:
1. Go to **Data** → Click your data asset (e.g., `taxi-data-secure`)
2. Click the **Consume** tab
3. Copy the code provided - it looks like this:

```python
# Auto-generated from Data Asset "Consume" tab
import mltable
from azure.ai.ml import MLClient
from azure.identity import DefaultAzureCredential

ml_client = MLClient.from_config(credential=DefaultAzureCredential())
data_asset = ml_client.data.get("taxi-data-secure", version="1")

tbl = mltable.load(f'azureml:/{data_asset.id}')
df = tbl.to_pandas_dataframe()
df.head()
```

4. Then add MLflow tracking to your training:

```python
# Setup MLflow experiment tracking
import mlflow
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split

mlflow.set_experiment("epa-mvp-experiment")

with mlflow.start_run(run_name="rf-baseline"):
    # Log parameters
    mlflow.log_param("n_estimators", 100)
    mlflow.log_param("max_depth", 10)
    
    # Train model
    model = RandomForestRegressor(n_estimators=100, max_depth=10)
    # ... your training code ...
    
    # Log metrics
    mlflow.log_metric("r2_score", 0.85)
    mlflow.log_metric("rmse", 2.5)
    
    # Log model
    mlflow.sklearn.log_model(model, "model")
    
    print("Run logged to MLflow!")
```

5. View your experiments in **Jobs** → **All experiments** → `epa-mvp-experiment`

📖 **Learn more:** [Track ML experiments with MLflow](https://learn.microsoft.com/en-us/azure/machine-learning/how-to-use-mlflow-cli-runs)

💡 **EPA Tip:** This notebook approach could become the foundation of your EPA project's ML component - with proper experiment tracking from day one!

---

## �🎉 Workshop Complete!

You've completed the full workshop:

- **Activities 1-5:** Audited legacy infrastructure, identified vulnerabilities
- **Activities 6-10:** Built parameterized templates, deployed securely
- **Activity 11:** Applied security principles to ML workloads

**Well done! 🎓**
