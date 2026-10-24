# Getting started

Everything below is one-time setup per subscription. Terraform state and deploys use OIDC, so there are no stored Azure secrets.

## 1. Azure

1. **State storage.** Create a resource group and a storage account with a container named `tfstate` (versioning on, public access off). Note the resource group and account names.
2. **Deployment identity.** Create an app registration (or a user-assigned managed identity) for deployments. Add a **federated credential** per environment: issuer `https://token.actions.githubusercontent.com`, subject `repo:<your-org>/<this-repo>:environment:<dev|test|prod>`.
3. **Permissions.** Grant that identity Contributor on the environment's subscription or resource group, and Storage Blob Data Contributor on the state storage account.

## 2. GitHub environments

Create environments `dev`, `test`, and `prod` in this repository. Require reviewers on `prod`. On each environment set these **variables** (not secrets):

| Variable | Value |
| --- | --- |
| `AZURE_CLIENT_ID` | Client ID of the deployment identity |
| `AZURE_TENANT_ID` | Your Entra tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Subscription for that environment |
| `TFSTATE_RESOURCE_GROUP` | State resource group |
| `TFSTATE_STORAGE_ACCOUNT` | State storage account |

## 3. Portal credentials

The portal uses separate credentials, each used by one component. Store them in Key Vault after the first deployment creates the vault; never in this repository.

| Credential | Used by | Notes |
| --- | --- | --- |
| GitHub App (App ID and private key) | Ingestion | Usage metrics and AI Credits reports |
| Classic PAT (`read:org`, `admin:enterprise`) | Directory sync only | SCIM and seats; record its expiry |
| OAuth app registrations | Portal sign-in | Entra and GitHub, separate from the above |

The portal repository's decision record (§12.4) is the source of truth for these.

## 4. First deploy

1. Set `portal.version` in `config/deployment.yml` to a released portal version.
2. Run **Deploy** with `environment: dev` and `apply: false`, and read the plan.
3. Run it again with `apply: true`.

## Network

`dev` can use `network.mode = "create"`. For `test` and `prod`, the recommended mode is `existing`: pass the IDs of subnets and DNS zones that your network team already owns. Terraform reads them and never changes them.
