# GitHub Copilot usage metrics portal: deployment template

This repository holds **configuration only**. The portal itself lives in
[github-copilot-enterprise-usage-metrics](https://github.com/MohamedSahbi/github-copilot-enterprise-usage-metrics);
this repository pins a released version of it and deploys it to your Azure subscription with your settings.

## Use it

1. Click **Use this template** and create a **private** repository in your organization.
2. Edit `config/dev.tfvars`, `config/test.tfvars`, and `config/prod.tfvars` (look for `REPLACE`).
3. Follow [docs/getting-started.md](docs/getting-started.md): Azure OIDC, state storage, GitHub environments, and the GitHub credentials the portal needs.
4. Set `portal-version` to a released portal version, then run the **Deploy** workflow for `dev`, plan first.
5. Fill in [docs/deployment-note.md](docs/deployment-note.md) with your organization-specific facts. Keep it in your private repository only.

## What is here

| Path | Purpose |
| --- | --- |
| `portal-version` | The portal release this repository deploys (for example `0.1.0`). |
| `config/*.tfvars` | Non-secret settings per environment: region, optional modules, network mode, alert emails. |
| `.github/workflows/deploy.yml` | Checks out the pinned portal release and runs Terraform with your settings. |
| `docs/` | Setup guide and the deployment-note template. |

## Updating

Change `portal-version` to a newer release tag and run the workflow. You never merge from the upstream project, and nothing here is a copy of portal code, so there are no conflicts to resolve. Changing portal behaviour means forking the portal repository and pointing `PORTAL_REPO` in the workflow at your fork.

## Status

Early. The portal is under construction, so a released version does not exist yet and the deploy workflow has not run against a real subscription. Treat this as the intended shape, and expect it to change before the first release.

## Rules for this repository

- No secrets in this repository or in `*.tfvars`. Secrets live in Azure Key Vault and in GitHub environment secrets.
- Keep it private once it contains real values.
