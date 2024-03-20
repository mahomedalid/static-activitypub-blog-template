#!/bin/bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -e "private.pem" ]; then
    echo "Creating private and public keys"
    openssl genrsa -out private.pem 2048
    openssl rsa -in private.pem -outform PEM -pubout -out public.pem
fi

PUBLIC_KEY=$(cat public.pem)
PRIVATE_KEY=$(cat private.pem)

CONFIG_FILE="$script_dir/../config.json"
DEPLOY_FILE="$script_dir/../deploy.json"
STATIC_WEB_URL=$(cat $CONFIG_FILE  | jq '.baseDomain' -r)
AZURE_FUNCTION_NAME=$(cat $DEPLOY_FILE  | jq '.azureFunctionsName' -r)
RESOURCE_GROUP=$(cat $DEPLOY_FILE  | jq '.resourceGroupName' -r)

echo "Generating actor file"

jq -n --argfile config $CONFIG_FILE --arg publicKey "$PUBLIC_KEY" -f "$script_dir/templates/actor" > "$script_dir/../blog/static/socialweb/actor"

FEDIVERSE_HOSTNAME=$(cat $CONFIG_FILE | jq -r '.baseDomain | sub("^https://"; "@") | sub("/"; "")')

echo -e "\nThis blog can be followed in the fediverse by @blog$FEDIVERSE_HOSTNAME" >> "$script_dir/../README.md"

sed -i "s/^fediverseHandle=.*/fediverseHandle='@blog$FEDIVERSE_HOSTNAME'/" "$script_dir/../blog/hugo.toml"

echo "Generating webfinger file"

jq -n --argfile config $CONFIG_FILE --arg publicKey "$PUBLIC_KEY" -f "$script_dir/templates/webfinger" > "$script_dir/../blog/static/.well-known/webfinger"

echo "Configuring inbox"

actorKeyId="${STATIC_WEB_URL}socialweb/actor#main-key"

az functionapp config appsettings set --name $AZURE_FUNCTION_NAME \
     --resource-group $RESOURCE_GROUP --settings BaseDomain="$STATIC_WEB_URL" ActorName=blog ActorKeyId="$actorKeyId"

az functionapp config appsettings set --name $AZURE_FUNCTION_NAME \
     --resource-group $RESOURCE_GROUP --settings ActorPrivatePEMKey="$PRIVATE_KEY"

echo "Commiting"

git add $script_dir/..
git commit -am "Initial setup"
git push -u origin HEAD