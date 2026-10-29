# Getting started

Everything below is one-time setup per subscription. Terraform state and deploys use OIDC, so there are no stored Azure secrets.

## 1. Azure

1. **State storage.** Run the portal's `scripts/bootstrap-state.sh <resource-group> <storage-account> <location> [principal-object-id]` once (Azure CLI, signed in to the subscription). It creates the account with a `tfstate` container, versioning on and public access off. Note the resource group and account names.
2. **Deployment identity.** Create an app registration (or a user-assigned managed identity) for deployments. Add a **federated credential** per environment: issuer `https://token.actions.githubusercontent.com`, subject `repo:<your-org>/<this-repo>:environment:<dev|test|prod>`.
3. **Permissions.** Grant that identity **Contributor and User Access Administrator** on the environment's subscription or resource group (the stack creates role assignments), and Storage Blob Data Contributor on the state storage account.
4. **Existing resource group.** To deploy into one, set `existing_resource_group_name` in the tfvars. The state storage can live in the same group: pass it to `bootstrap-state.sh`.

## 2. Pipeline

Choose one wrapper; both call the portal's `scripts/deploy-infra.sh`.

**Azure Pipelines** (`azure-pipelines.yml`): create an Azure Resource Manager service connection with **workload identity federation** and put its name, plus the state resource group and account, in the `variables` block of the file (marked REPLACE). The service connection identity needs the same role assignments as step 3. Create Azure DevOps environments named exactly `dev`, `test` and `prod` (Pipelines > Environments) before the first run, and add approvals on `prod`. Run the pipeline manually and pick the environment; leave `apply` off for a plan first.

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

## 5. First deploy

1. Set `portal.version` in `config/deployment.yml` to a released portal version.
2. Run **Deploy** with `environment: dev` and `apply: false`, and read the plan.
3. Run it again with `apply: true`.
4. Every apply is followed by a **Database** stage (Azure Pipelines): it runs the pinned release's `scripts/deploy-db.sh`, which applies migrations and maps the runtime identities to their SQL roles. Re-running is safe. The service connection's identity must be in the SQL server's Entra admin group; a release without `scripts/deploy-db.sh` skips the stage with a warning.
5. Once access is bootstrapped, run it with `apply: true` and `deployPortal: true` to build the pinned release and deploy the portal code to the web app, and `deployFunctions: true` to deploy the metrics and directory Function Apps. They need a portal release that includes `scripts/deploy-portal.sh` and `scripts/deploy-functions.sh`, and an agent that can reach the apps' deployment endpoints (public network access enabled, or a self-hosted agent with a private route).

Notes:
- The apply job has a 120 minute limit. Some Azure changes are slow; switching `sql_database_sku` between provisioned and serverless after the first deploy can take a long time, so choose the SKU before the first deploy.
- If an apply is cancelled, it leaves the Terraform state locked. Break the lease on the state blob (`az storage blob lease break`) or run `terraform force-unlock`, then plan again.

## Data operations

`data-operations.yml` is a second Azure Pipelines pipeline, separate from the deploy pipeline. It holds only your
values and a pointer: its stages and steps are loaded at run time with `extends` from
`azure-pipelines/data-operations.yml` in this template repository, so your deployment repository never carries a
copy of them. Fill in the same `variables` values as `azure-pipelines.yml`, plus an Azure DevOps service connection of
type GitHub that can read this repository (`endpoint`), then register it as its own pipeline. It never runs on a push
or a deploy: queue it by hand, pick the environment and an operation. Its identity must be in the SQL server's Entra admin group. It needs a
portal release that includes `scripts/data-ops.sh`.

| Operation | What it does |
| --- | --- |
| `status` | Read-only. The metrics state of each day from `fromDay` to yesterday, per organization, and any synthetic run IDs |
| `remove-synthetic` | Dry run. Deletes published metrics runs the loader did not write inside a transaction, prints the counts, rolls back |
| `remove-synthetic-execute` | Deletes them, only if the fact-row count still equals `expectFactRows` from the dry run |

The portal's `docs/runbooks/metrics-history-import.md` gives the order (status, dry run, delete, then `backfill_from`).

## Outbound access for the pipeline

The deploy agent must reach `github.com` over HTTPS (port 443) to clone the portal release (`MohamedSahbi/github-copilot-enterprise-usage-metrics`, or your fork). If your organization uses an outbound allowlist or proxy, add `github.com`. Building the portal application (not part of this template's deploy) also fetches the upstream submodule from `github.com`; the same allowlist entry covers it.

## Network

`dev` can use `network.mode = "create"`. For `test` and `prod`, the recommended mode is `existing`: pass the IDs of subnets and DNS zones that your network team already owns. Terraform reads them and never changes them.
