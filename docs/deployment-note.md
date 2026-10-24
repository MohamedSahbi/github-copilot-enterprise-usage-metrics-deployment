# Deployment note (private)

Human-only facts about your deployment. Keep the filled-in version in your **private** repository only.

Anything a tool or the portal reads does not belong here:

- Organization facts (enterprise slug, organizations, login suffix, group prefix, directory provider, tenant ID) live in `config/<environment>.tfvars`.
- Which portal version to deploy lives in `config/deployment.yml`.
- Secrets live in Key Vault, never in this repository.

| Fact | Value |
| --- | --- |
| Portal admins and how to reach them | |
| Business owner of the deployment | |
| Alert mailbox owner | |
| Azure subscription per environment | dev: / test: / prod: |
| GitHub classic PAT expiry date | |
| GitHub App key last rotated | |
| Decisions specific to this organization, and why | |
