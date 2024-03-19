#!/bin/bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -e "private.pem" ]; then
    echo "Creating private and public keys"
    openssl genrsa -out private.pem 2048
    openssl rsa -in private.pem -outform PEM -pubout -out public.pem
fi

PUBLIC_KEY=$(cat public.pem | tr -d '\n')
PRIVATE_KEY=$(cat private.pem | tr -d '\n')

echo "Retrieving config values from Azure deployment"

DEPLOYMENT_NAME=$1

AZURE_FUNCTION_NAME=$(az deployment sub show --name $DEPLOYMENT_NAME --query properties.outputs.azureFunctionsName.value -o tsv)
STATIC_WEB_URL=$(az deployment sub show --name $DEPLOYMENT_NAME --query properties.outputs.staticWebsiteUrl.value -o tsv)
AZURE_FUNCTION_ENDPOINT=$(az deployment sub show --name $DEPLOYMENT_NAME --query properties.outputs.azureFunctionsEndpoint.value -o tsv)
RESOURCE_GROUP=$(az deployment sub show --name $DEPLOYMENT_NAME --query properties.outputs.resourceGroupName.value -o tsv)

deployment_file="$script_dir/../deploy.json"

az deployment sub show --name $DEPLOYMENT_NAME --query properties.outputs | jq -r 'with_entries(.value |= .value)' > $deployment_file

config_file="$script_dir/../config.json"

echo "Generating base config file"

jq -n --arg baseDomain "$STATIC_WEB_URL" \
    --arg inboxEndpoint "https://$AZURE_FUNCTION_ENDPOINT/api/Inbox" \
    --arg actorName "blog" \
    --arg authorUsername "@mapache@hachyderm.io" \
    --arg azFuncName "$AZURE_FUNCTION_NAME" \
    '{ "baseDomain": $baseDomain, "actorName": $actorName, "inboxEndpoint": $inboxEndpoint, "authorUsername": $authorUsername }' > $config_file

echo "Generating actor file"

jq -n --argfile config $config_file --arg publicKey "$PUBLIC_KEY" -f "$script_dir/templates/actor" > "$script_dir/../blog/static/socialweb/actor"

echo "Generating webfinger file"

jq -n --argfile config $config_file --arg publicKey "$PUBLIC_KEY" -f "$script_dir/templates/webfinger" > "$script_dir/../blog/static/.well-known/webfinger"

echo "Configuring inbox"

actorKeyId="${STATIC_WEB_URL}blog#main-key"

az functionapp config appsettings set --name $AZURE_FUNCTION_NAME \
     --resource-group $RESOURCE_GROUP --settings BaseDomain="$STATIC_WEB_URL" ActorName=blog ActorKeyId="$actorKeyId"

az functionapp config appsettings set --name $AZURE_FUNCTION_NAME \
     --resource-group $RESOURCE_GROUP --settings ActorPrivatePEMKey="$PRIVATE_KEY"

echo "Commiting"

git add .
git commit -am "Initial setup"
git push -u origin HEAD