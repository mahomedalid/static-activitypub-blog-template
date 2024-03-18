#!/bin/bash
for file in public/socialweb/*; do
    fileName=$(basename "$file")

    # Use Azure CLI to set content type
    az storage blob update -c "\$web" -n "socialweb/$fileName" --content-type "application/activity+json;" --account-key "$AZURE_STORAGE_KEY" --account-name "$AZURE_STORAGE_ACCOUNT"
done

#az afd endpoint purge --resource-group myRGFD --profile-name contosoafd --endpoint-name myendpoint --domains www.contoso.com --content-paths '/scripts/*'