#!/bin/bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

NOTES_DIR=$(cd $script_dir/../blog/public/socialweb/notes && pwd)

CONFIG_FILE="$script_dir/../config.json"
DEPLOY_FILE="$script_dir/../deploy.json"
STATIC_WEB_URL=$(cat $CONFIG_FILE  | jq '.baseDomain' -r)
AZURE_FUNCTION_NAME=$(cat $DEPLOY_FILE  | jq '.azureFunctionsName' -r)
RESOURCE_GROUP=$(cat $DEPLOY_FILE  | jq '.resourceGroupName' -r)

AZ_FUNCTIONS_SETTINGS=$(az functionapp config appsettings list --name $AZURE_FUNCTION_NAME --resource-group $RESOURCE_GROUP)

export ACTIVITYPUB_DOTNET_PRIVATEKEY=$(echo $AZ_FUNCTIONS_SETTINGS | jq -r '.[] | select(.name == "ActorPrivatePEMKey").value')
export ACTIVITYPUB_DOTNET_KEYID=$(echo $AZ_FUNCTIONS_SETTINGS | jq -r '.[] | select(.name == "ActorKeyId").value')
export ACTIVITYPUB_DOTNET_STORAGE_CONNECTIONSTRING=$(echo $AZ_FUNCTIONS_SETTINGS | jq -r '.[] | select(.name == "CoreStorageConnection").value')

for file in $NOTES_DIR/*; do
    echo $file

    BroadcastPost --notePath $file
done