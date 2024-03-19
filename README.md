# ActivityPub-Enabled Static Site 

Template to create a static website blog activitypub enabled powered by Azure.

## Getting Started

## Pre-requisites

1. An Azure subscription, all the resources in this template are in the free tier. See [Azure Free Tier](https://azure.microsoft.com/en-us/free/) for more information.
1. Use this template to create a new repository. See [Creating a Repository From a Template](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template) for more information.

### Method 1. GitHub Codespaces

1. Open/create a GitHub Codespace in this repository. It will take a few minutes.
2. In the terminal window execute `az login` or `az login --use-device-code` to login in Azure.
3. 
5. Execute `./utils/00-create-sp.sh`, save contents into AZ_SP_CREDENTIALS
6. Deploy infra:

Basic: 

```bash
az deployment sub create --name staticsite01 \
 --location westus \
 --template-file main.bicep \
 --parameters resourceGroupName=rg-staticsite01 resourceGroupLocation=westus 
```

Existing:

```bash
az deployment sub create --name apmain2 \
 --location westus \
 --template-file main.bicep \
 --parameters resourceGroupName=rg-staticap3 resourceGroupLocation=westus hostingPlanCreate=existing hostingPlanName=WestUSLinuxDynamicPlan hostingPlanResourceGroupName=ducks
```

6. Build config

```bash
./utils/02-setup.sh apmain2
```


5. Open github workflow actions and deploy functions


TODO:

CONF 


Auto create static/socialweb/actor
-- NO for MVP = Auto create static/socialweb/featured
Auto create private keys
