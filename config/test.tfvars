# Non-secret configuration for the test environment. Replace the values marked REPLACE.
location    = "westeurope" # REPLACE with your Azure region
name_prefix = "cmp"        # REPLACE: 2-12 lowercase letters or digits

modules = {
  ai_credits    = false
  budget_lookup = false
  feedback      = true
}

alert_emails = ["team@example.com"] # REPLACE with a team mailbox or distribution list

# Enterprise default: reference a network that already exists.
network = {
  mode      = "existing"
  subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/REPLACE/providers/Microsoft.Network/virtualNetworks/REPLACE/subnets/REPLACE" # REPLACE
}

# Optional: reference the shared SQL server and database instead of creating one.
# existing_sql = {
#   server_id   = "/subscriptions/.../providers/Microsoft.Sql/servers/REPLACE"
#   database_id = "/subscriptions/.../providers/Microsoft.Sql/servers/REPLACE/databases/REPLACE"
# }
