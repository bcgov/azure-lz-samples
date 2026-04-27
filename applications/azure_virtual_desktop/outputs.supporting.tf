output "log_analytics_workspaces" {
  description = "Map of Log Analytics Workspace outputs keyed by the same keys used in var.log_analytics_workspaces."
  value = {
    for key, law in module.log_analytics_workspaces : key => {
      id           = law.id
      name         = law.name
      workspace_id = law.workspace_id
    }
  }
}

output "log_analytics_workspace_primary_shared_keys" {
  description = "Primary shared keys for all Log Analytics Workspaces. Sensitive."
  value = {
    for key, law in module.log_analytics_workspaces : key => law.primary_shared_key
  }
  sensitive = true
}

output "key_vaults" {
  description = "Map of Key Vault outputs keyed by the same keys used in var.key_vaults."
  value = {
    for key, kv in module.key_vaults : key => {
      id                                 = kv.id
      name                               = kv.name
      uri                                = kv.uri
      private_endpoint_id                = kv.private_endpoint_id
      avd_local_admin_username_secret_id = kv.avd_local_admin_username_secret_id
      avd_local_admin_password_secret_id = kv.avd_local_admin_password_secret_id
    }
  }
}
