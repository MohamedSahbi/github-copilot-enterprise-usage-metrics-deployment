# GitHub Copilot usage metrics portal: deployment template

This repository holds **configuration only**. The portal itself lives in
[github-copilot-enterprise-usage-metrics](https://github.com/MohamedSahbi/github-copilot-enterprise-usage-metrics);
this repository pins a released version of it and deploys it to your Azure subscription with your settings.

## Use it

1. Click **Use this template** and create a **private** repository in your organization.
2. Edit `config/dev.tfvars`, `config/test.tfvars`, and `config/prod.tfvars` (look for `REPLACE`).
3. Follow [docs/getting-started.md](docs/getting-started.md): Azure OIDC, state storage, GitHub environments, and the GitHub credentials the portal needs.
4. Set `portal.version` in `config/deployment.yml` to a released portal version, then run the pipeline for `dev` (Azure Pipelines `azure-pipelines.yml` or the GitHub Actions **Deploy** workflow). It runs Terraform init, validate and plan first; apply is a separate step that waits for the environment approval.

Prerequisite: the pipeline agent needs outbound HTTPS access to `github.com` (see [Outbound access](docs/getting-started.md#outbound-access-for-the-pipeline)).
5. Fill in [docs/deployment-note.md](docs/deployment-note.md) with the human-only facts (admins, expiry and rotation dates). Keep it in your private repository only.

## What is here

| Path | Purpose |
| --- | --- |
| `config/deployment.yml` | Settings the pipeline reads: which portal repository and release to deploy. |
| `config/*.tfvars` | Settings Terraform and the portal read, per environment: organization facts, region, optional modules, network mode, alert emails. |
| `azure-pipelines.yml`, `azure-pipelines/` | Azure Pipelines wrapper: fetches the pinned portal release, then runs Terraform init, validate, plan and (after approval) apply through its deploy script, followed by the Database stage and the optional portal and functions code deploys. |
| `.github/workflows/deploy.yml` | The same for GitHub Actions. |
| `docs/` | Setup guide and the deployment-note template. |

## Updating

Change `portal.version` to a newer release tag and run the workflow. You never merge from the upstream project, and nothing here is a copy of portal code, so there are no conflicts to resolve. Changing portal behaviour means forking the portal repository and setting `portal.repository` in `config/deployment.yml` to your fork.

## Taking template changes

A repository created from this template shares no history with it. To take newer wrappers, documentation or configuration keys, review the template's changes and copy them over by hand in a reviewed pull request. Never overwrite your own `config/*` values. Portal upgrades are separate: change `portal.version`.

## Status

Early. The infrastructure deployment has been run end to end for a `dev` environment through Azure Pipelines. The portal application itself is still under construction, so expect changes before the first 1.0 release. Pin an exact portal version and read its release notes before upgrading.

## Rules for this repository

- Structured values go in `*.tfvars` or `config/deployment.yml`, never in Markdown.
- No secrets in this repository or in `*.tfvars`. Secrets live in Azure Key Vault and in GitHub environment secrets.
- Keep it private once it contains real values.
