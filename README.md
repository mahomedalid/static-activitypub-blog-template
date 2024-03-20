# ActivityPub-Enabled Static Site 

Template to create a static website blog activitypub enabled powered by Azure.

## Getting Started

## Pre-requisites

1. An Azure subscription, all the resources in this template are in the free tier. See [Azure Free Tier](https://azure.microsoft.com/en-us/free/) for more information.
1. Use this template to create a new repository. See [Creating a Repository From a Template](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template) for more information.

### Method 1. GitHub Codespaces

1. Open a GitHub Codespace.
2. `az login` or `az login --use-device-code`
3. Give the deployment a meaningful name `export STATIC_DEPLOYMENT_NAME=myblog`
4. Execute `./utils/01-create-sp.sh $STATIC_DEPLOYMENT_NAME`, save contents of the json into AZ_SP_CREDENTIALS GitHub actions secrets.
5. Deploy infra:

```bash
cd infra && ./01-deploy.sh $STATIC_DEPLOYMENT_NAME && cd ..
```

or, you can define your globally unique name

```bash
cd infra && ./01-deploy.sh $STATIC_DEPLOYMENT_NAME myblogstatic && cd ..
```

If you have an existing web plan, you need to do it in the difficult way:

```bash
az deployment sub create --name $STATIC_DEPLOYMENT_NAME \
 --location westus \
 --template-file main.bicep \
 --parameters resourceGroupName=rg-$STATIC_DEPLOYMENT_NAME resourceGroupLocation=westus \
 hostingPlanCreate=existing hostingPlanName=<myplanname> hostingPlanResourceGroupName=<myresourcegroup>
```

6. Build config

```bash
./utils/02-setup.sh $STATIC_DEPLOYMENT_NAME && ./utils/03-build-config.sh
```

7. Open github workflow actions and deploy functions. 
8. Open github workflow and deploy your blog.

9. Follow your blog in the fediverse, information about the blog is on the README.md, config.json and deploy.json files.

10. Update the setting `authorUsername` in the `config.json` file, this is another author account in case you have a personal fediverse account.

11. Add a post into `blog/content/post`, make sure it merges to main, either with a PR or directly.

## Next steps

### Custom Domain

1. Configure your domain: [Custom domains with Azure Static Web Apps](https://learn.microsoft.com/en-us/azure/static-web-apps/custom-domain).
2. Modify the `baseUrl` setting of the `hugo.toml` file.
3. Modify the `config.json` file updating `baseDomain`. setting of the `hugo.toml` file. Execute `utils/03-build-config.sh`.
4. Re-deploy your blog using GitHub actions.

### Themes and configuration

This static site is a fully featured, not customized `hugo` site. Check `https://github.com/gohugoio/hugo/` for customization and themes installation.

## Contribute

I hope to see people forking this for Vercel, AWS, GCP and other implementations of the Inbox!