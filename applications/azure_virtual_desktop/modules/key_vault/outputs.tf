output "id" {
  description = "Resource ID of the Key Vault."
  value       = azurerm_key_vault.this.id
}

output "name" {
  description = "Name of the Key Vault."
  value       = azurerm_key_vault.this.name
}

output "uri" {
  description = "Vault URI of the Key Vault."
  value       = azurerm_key_vault.this.vault_uri
}

output "avd_local_admin_username_secret_id" {
  description = "Resource ID of the AVD-Local-Admin-Username secret, or null when create_local_admin_secrets is false."
  value       = try(azurerm_key_vault_secret.avd_local_admin_username["enabled"].id, null)
}

output "avd_local_admin_password_secret_id" {
  description = "Resource ID of the AVD-Local-Admin-Password secret, or null when create_local_admin_secrets is false."
  value       = try(azurerm_key_vault_secret.avd_local_admin_password["enabled"].id, null)
}

output "private_endpoint_id" {
  description = "Resource ID of the Key Vault private endpoint."
  value       = azurerm_private_endpoint.this.id
}
