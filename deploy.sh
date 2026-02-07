#!/bin/bash

# Kids Story Generator - Quick Deploy Script
# This script automates the Azure deployment process

echo "🎨 Kids Story Generator - Azure Deployment Script"
echo "=================================================="
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first:"
    echo "https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if logged in to Azure
echo "Checking Azure login status..."
az account show &> /dev/null
if [ $? -ne 0 ]; then
    echo "Please login to Azure:"
    az login
fi

# Configuration
read -p "Enter a unique name for your app (lowercase, no spaces): " APP_NAME
read -p "Enter your Azure region (default: eastus): " REGION
REGION=${REGION:-eastus}
read -sp "Enter your Anthropic API Key: " API_KEY
echo ""

RESOURCE_GROUP="${APP_NAME}-rg"
STORAGE_ACCOUNT="${APP_NAME}storage"
FUNCTION_APP="${APP_NAME}-function"
STATIC_WEB_APP="${APP_NAME}-web"

echo ""
echo "Configuration:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Region: $REGION"
echo "  Function App: $FUNCTION_APP"
echo "  Static Web App: $STATIC_WEB_APP"
echo ""
read -p "Continue with deployment? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo "Deployment cancelled."
    exit 0
fi

echo ""
echo "📦 Step 1: Creating Resource Group..."
az group create --name $RESOURCE_GROUP --location $REGION

echo ""
echo "💾 Step 2: Creating Storage Account..."
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location $REGION \
  --sku Standard_LRS

echo ""
echo "⚡ Step 3: Creating Function App..."
az functionapp create \
  --resource-group $RESOURCE_GROUP \
  --consumption-plan-location $REGION \
  --runtime node \
  --runtime-version 18 \
  --functions-version 4 \
  --name $FUNCTION_APP \
  --storage-account $STORAGE_ACCOUNT

echo ""
echo "🔑 Step 4: Setting API Key..."
az functionapp config appsettings set \
  --name $FUNCTION_APP \
  --resource-group $RESOURCE_GROUP \
  --settings ANTHROPIC_API_KEY="$API_KEY"

echo ""
echo "📤 Step 5: Deploying Function Code..."
cd azure-function
npm install
func azure functionapp publish $FUNCTION_APP

echo ""
echo "🌐 Step 6: Creating Static Web App..."
az staticwebapp create \
  --name $STATIC_WEB_APP \
  --resource-group $RESOURCE_GROUP \
  --location eastus2

echo ""
echo "🔧 Step 7: Enabling CORS..."
az functionapp cors add \
  --name $FUNCTION_APP \
  --resource-group $RESOURCE_GROUP \
  --allowed-origins "*"

echo ""
echo "📋 Getting Function URL..."
FUNCTION_URL=$(az functionapp function show \
  --name $FUNCTION_APP \
  --resource-group $RESOURCE_GROUP \
  --function-name generateStory \
  --query "invokeUrlTemplate" -o tsv)

echo ""
echo "✅ Deployment Complete!"
echo "=================================="
echo ""
echo "Your Function URL: $FUNCTION_URL"
echo ""
echo "Next Steps:"
echo "1. Update story-generator.html with your Function URL:"
echo "   Replace the fetch URL with: $FUNCTION_URL"
echo ""
echo "2. Deploy your static web app:"
echo "   - Go to Azure Portal > Static Web Apps > $STATIC_WEB_APP"
echo "   - Upload your story-generator.html as index.html"
echo ""
echo "3. Get your Static Web App URL:"
echo "   az staticwebapp show --name $STATIC_WEB_APP --resource-group $RESOURCE_GROUP --query \"defaultHostname\" -o tsv"
echo ""
echo "Happy story generating! 📚✨"
