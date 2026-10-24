# Non-secret configuration for the dev environment. Replace the values marked REPLACE.
# Secrets never go here; they live in Key Vault (see docs/getting-started.md).
location    = "westeurope" # REPLACE with your Azure region
name_prefix = "cmp"        # REPLACE: 2-12 lowercase letters or digits

modules = {
  ai_credits    = false
  budget_lookup = false
  feedback      = true
}

alert_emails = ["team@example.com"] # REPLACE with a team mailbox or distribution list

# Development only: no private endpoints. Keep true for test and prod.
private_endpoints_enabled = false

network = {
  mode = "create"
}
