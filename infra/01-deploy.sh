#!/bin/bash

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if the user is logged in
if ! az account show &> /dev/null; then
    echo "Please log in to your Azure account using 'az login' before running this script."
    exit 1
fi

# Azure AD Service Principal creation

# Parameters
appName="$1"
location="westus"

if [ -n "$2" ]; then
  storageNameParam="storageAccountName=$2"
else
  storageNameParam=""
fi

az deployment sub create --name $appName \
 --location $location \
 --template-file main.bicep \
 --parameters resourceGroupName=rg-$appName resourceGroupLocation=$location $storageNameParam