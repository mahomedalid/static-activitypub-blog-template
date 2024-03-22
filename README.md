# ActivityPub-Enabled Static Site Template

Create a static website blog with ActivityPub integration, powered by Hugo and Azure.

## Getting Started

### Prerequisites

1. You'll need an Azure subscription, but don't worry—all the resources in this template fall under the free tier. For more information, check out the [Azure Free Tier](https://azure.microsoft.com/en-us/free/). With some effort you could also setup all of this in your own server.
2. In the easier route you also need a GitHub account, but also you can run all the bash scripts in your computer, you would need a Linux box with bash, jq and az cli installed. And a bunch of figure it out.
3. Your own repo based in this template. It can be private or public, it does not matter, no private keys or secrets are pushed as files. Learn how to do this from [Creating a Repository From a Template](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template).
4. A drink, either a beer, tea, coffee, water. Hydratation is important, and there are a few steps that take more than one minute.

### Method 1: GitHub Codespaces

> [!IMPORTANT]
> Do not be overwhelmed by these instructions, most of them are just copy paste, and everything should be installed already.
>
> I decided to not hide the steps under a big one script, and create modular steps instead, in case someone wants to play and extend this repo.
> 
[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/mahomedalid/static-activitypub-blog-template?quickstart=1)

#### Check the demo video with detailed instructions!

[![ActivityPub-Enabled Static Sites in 10 min](https://i.ytimg.com/vi/4Il3TUbo7WY/maxresdefault.jpg)]([https://www.youtube.com/watch?v=4Il3TUbo7WY](https://www.youtube.com/embed/ye39FHlAGPE?si=4Il3TUbo7WY&amp;start=175) "ActivityPub-Enabled Static Sites in 10 min")    

1. Launch a GitHub Codespace from your repository. See [Creating a Codespace for your repository](https://docs.github.com/en/codespaces/developing-in-a-codespace/creating-a-codespace-for-a-repository). It would have all the dependencies required and installed. Your first drink sip is here.
2. Run `az login --use-device-code` to login to Azure. If you cannot use device code use `az login`, copy the redirect url, and use curl/wget to hit in in a new terminal.
3. Assign a meaningful name to your deployment by executing `export STATIC_DEPLOYMENT_NAME=myblog`. Do not stress about it, it is just a reference if you have more than one deployment in Azure.
4. Run `./utils/01-create-sp.sh $STATIC_DEPLOYMENT_NAME` and save the JSON contents into the GitHub Actions secrets as AZ_SP_CREDENTIALS. **Important: just the JSON content, no other output, and this is a secret.** Take care of it. If you loose the credentials they cannot be retrieved again, but you can either reset the credentials or create a new Service Principal. The SP will act in your behalf.
5. Deploy infrastructure (and check that you have your drink at hand, this will take 2-5 minutes):

```bash
cd infra && ./01-deploy.sh $STATIC_DEPLOYMENT_NAME && cd ..
```

The storage account should be unique in the whole Azure, that script will auto-generate an ugly, but unique name. Alternatively, you can try to suply your globally unique name (ex. mapachestatic):

```bash
cd infra && ./01-deploy.sh $STATIC_DEPLOYMENT_NAME mapachestatic && cd ..
```

> Note: The script will use a free consumption web plan (SKU Y1), if you want to use an existing web plan, you'll need to take a more challenging route, for example:

  ```bash
  LOCATION=westus
  az deployment sub create --name $STATIC_DEPLOYMENT_NAME \
   --location $LOCATION \
   --template-file main.bicep \
   --parameters resourceGroupName=rg-$STATIC_DEPLOYMENT_NAME resourceGroupLocation=$LOCATION \
   hostingPlanCreate=existing hostingPlanName=_myplanname_ hostingPlanResourceGroupName=_myresourcegroup_
  ```

6. Build the config:

```bash
./utils/02-setup.sh $STATIC_DEPLOYMENT_NAME && ./utils/03-build-config.sh
```

This will generate and push two files in the repo: `deploy.json` and `config.json`. It will also update the README.md with a working link to your new static site!

7. Open GitHub Actions and run manually the workflow to deploy functions: *Deploy ActivityPub Inbox to Azure Function App*. Another drink sip.
8. Open GitHub Actions and run manually the workflow to deploy your blog: *Build and Deploy Blog*. To dot not worry if there is a previous failed execution, this time it should work.

9. Join the fediverse by following your blog. You can find information about the blog in the README.md, config.json, and deploy.json files. It is usually @blog@_yoursiteurl_
On mastodon, if you do not follow your account before creating posts, these won't show in the timeline.

11. Update the setting `authorUsername` in the `config.json` file. This is another author account in case you have a personal fediverse account, and gets mentioned in each post. 

12. Add a post into `blog/content/post`. There is a template you can copy paste in `blog/content/_template.md`. Ensure it merges to the main branch, either with a PR or directly. Do not forget to mark it as `draft=false`!

> After a few minutes the post should show in the site url, and in the fediverse.

14. Give me [feedback](https://github.com/mahomedalid/static-activitypub-blog-template/issues/new), follow me in the fediverse ([@mapache@hachyderm.io](https://hachyderm.io/@mapache)), subscribe to [my blog](https://maho.dev) or [my substack](https://mahopacheco.substack.com/), [watch a video on my channel](https://www.youtube.com/@TheRaccoonBytes), buy me a beer, plant a tree, take your wife to dinner, foster a stray dog, or share the repo with a close friend or the Fediverse. Anything helps. Love wins. Beer happens. The world is dying.

## Next Steps

### Custom Domain

I don't think many people in the fediverse will be proud of the "web.core.windows.net" domain, so I am guessing this section would be very popular.

1. Configure your domain: [Custom domains with Azure Static Web Apps](https://learn.microsoft.com/en-us/azure/static-web-apps/custom-domain).
2. Modify the `baseUrl` setting in the `hugo.toml` file.
3. Update the `baseDomain` setting in the `config.json` file. Execute `utils/03-build-config.sh`.
4. Re-deploy your blog using GitHub Actions.

### Themes and Configuration

This static site is based on a fully featured, uncustomized `hugo` site. Explore [Hugo](https://github.com/gohugoio/hugo/) for customization and theme installation.

However, there are 4 files who were changed to be able to include comments and subscribe features:

This can be copy pasted to a new theme:

* `themes/PaperMod/layouts/partials/comments.html`
* `themes/PaperMod/layouts/partials/extend_footer.html`

Basic css was included vanilla with this:

```html
<link crossorigin="anonymous" href="/css/custom.css" rel="preload stylesheet" as="style">
```

directly in the head (`themes/PaperMod/layouts/partials/head.html`).

There are better ways to do it, but I will let you go as complex as you want.

I also added a subscribe button into the header (`themes/PaperMod/layouts/partials/header.html`)  because PaperMod was messing with the `href`:

```html
<li><input type="button" onclick="showSubscribeModal();" value="Subscribe" /></li>
```

But it does not need to be a button, or be on the navigation bar, just make sure it executes `showSubscribeModal();`.

### Custom Modifications

Refer to the [ActivityPub blog series](https://maho.dev/2024/02/a-guide-to-implement-activitypub-in-a-static-site-or-any-website/) for in-depth explanations on bringing ActivityPub to a static site or any website.

## Contribute

We encourage forking this template for Vercel, AWS, GCP, and other implementations. Let's expand the Inbox together!

By "we" I mean me. I hope others join eventually.
