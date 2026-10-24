# Getting started

Everything below is one-time setup per subscription. Terraform state and deploys use OIDC, so there are no stored Azure secrets.

## 1. Azure

1. **State storage.** Run the portal's `scripts/bootstrap-state.sh <resource-group> <storage-account> <location> [principal-object-id]` once (Azure CLI, signed in to the subscription). It creates the account with a `tfstate` container, versioning on and public access off. Note the resource group and account names.
2. **Deployment identity.** Create an app registration (or a user-assigned managed identity) for deployments. Add a **federated credential** per environment: issuer `https://token.actions.githubusercontent.com`, subject `repo:<your-org>/<this-repo>:environment:<dev|test|prod>`.
3. **Permissions.** Grant that identity Contributor on the environment's subscription or resource group, and Storage Blob Data Contributor on the state storage account.

## 2. Pipeline

Choose one wrapper; both call the portal's `scripts/deploy-infra.sh`.

**Azure Pipelines** (`azure-pipelines.yml`): create an Azure Resource Manager service connection with **workload identity federation** and put its name, plus the state resource group and account, in the `variables` block of the file (marked REPLACE). Create Azure DevOps environments `dev`, `test`, `prod` and add approvals on `prod`. Run the pipeline manually and pick the environment; leave `apply` off for a plan first.

**GitHub Actions** (`.github/workflows/deploy.yml`): follow the next section.

## 3. GitHub environments (GitHub Actions only)

Create environments `dev`, `test`, and `prod` in this repository. Require reviewers on `prod`. On each environment set these **variables** (not secrets):

| Variable | Value |
| --- | --- |
| `AZURE_CLIENT_ID` | Client ID of the deployment identity |
| `AZURE_TENANT_ID` | Your Entra tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Subscription for that environment |
| `TFSTATE_RESOURCE_GROUP` | State resource group |
| `TFSTATE_STORAGE_ACCOUNT` | State storage account |

## 4. Portal credentials

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
