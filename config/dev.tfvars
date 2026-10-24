# Non-secret configuration for the dev environment. Replace the values marked REPLACE.
# Secrets never go here; they live in Key Vault (see docs/getting-started.md).
environment = "dev"
location    = "westeurope" # REPLACE with your Azure region
name_prefix = "cmp"        # REPLACE: 2-12 lowercase letters or digits

organization = {
  enterprise_slug    = "REPLACE-enterprise-slug"
  organizations      = ["REPLACE-org"]
  login_suffix       = "_REPLACE"                             # suffix of managed-user logins
  group_prefix       = "REPLACE-"                             # Entra group display-name prefix for business areas; "" = no group scoping
  directory_provider = "entra"                                # entra or csv
  entra_tenant_id    = "00000000-0000-0000-0000-000000000000" # REPLACE
}

modules = {
  ai_credits    = false
  budget_lookup = false
  feedback      = true
}

# Optional: deploy into a pre-existing resource group (the deploy identity needs Contributor and User Access Administrator on it).
# existing_resource_group_name = "REPLACE-rg"

# Required unless existing_sql is set. An Entra user, group or managed identity you pass in (Terraform creates nothing).
# object_id is the principal (object) ID. Azure SQL allows one admin; use a group to have several.
# sql_admin = {
#   login_username = "REPLACE-name"
#   object_id      = "00000000-0000-0000-0000-000000000000"
# }

# App Service plan SKU (default B1).
# app_service_sku = "B1"

alert_emails = ["team@example.com"] # REPLACE with a team mailbox or distribution list

# Development only: no private endpoints. Keep true for test and prod.
private_endpoints_enabled = false

network = {
  mode = "create"
}
