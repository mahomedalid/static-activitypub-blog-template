#!/bin/bash

# Get the directory of the script
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
socialweb_dir=$(cd $script_dir/../blog/public/socialweb && pwd)
prefix=$(cd $script_dir/../blog/public/ && pwd)

hugo deploy --maxDeletes 0 --logLevel debug

for file in $socialweb_dir/*; do
    filePath="${file#$prefix}"
    filePath="${filePath#?}"

    echo $filePath
    
    # Use Azure CLI to set content type
    az storage blob update -c "\$web" -n "$filePath" --content-type "application/activity+json;" --account-key "$AZURE_STORAGE_KEY" --account-name "$AZURE_STORAGE_ACCOUNT"
done

#az afd endpoint purge ...