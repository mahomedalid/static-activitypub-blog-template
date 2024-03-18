# ActivityPub-Enabled Static Site 

Template to create a static website blog activitypub enabled powered by Azure.

## Getting Started

### Method 1. GitHub Codespaces

1. Create a project based in this template.
2. Open a GitHub Codespace.
3. `az login` or `az login --use-device-code`
4. Deploy infra

az deployment sub create --name apmain  --location westus2  --template-file main.bicep --parameters resourceGroupName=staticap1 resourceGroupLocation=westus2

az deployment sub create --name apmain2  --location westus  --template-file main.bicep --parameters resourceGroupName=rg-staticap2 resourceGroupLocation=westus hostingPlanCreate=existing hostingPlanName=WestUSLinuxDynamicPlan hostingPlanResourceGroupName=ducks

5. Open github workflow actions and deploy functions


TODO:

CONF 

GitHub Secret - AZ_SP_CREDENTIALS
GitHub Action Var - AZURE_FUNCTIONAPP_NAME
Az Function config - BaseDomain -- "https://maho.dev",
Az Function config - ActorPrivatePEMKey -- BEGIN PRIVATE KEY
Az Function config - ActorKeyId -- "ActorKeyId": "https://maho.dev/blog#main-key"
Az Function actor - ActorName -- blog

Auto create static/socialweb/actor
Auto create static/socialweb/featured
Auto create private keys