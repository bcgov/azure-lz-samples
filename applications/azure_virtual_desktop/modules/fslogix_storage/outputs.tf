output "id" {
  description = "Resource ID of the FSLogix storage account."
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "Name of the FSLogix storage account."
  value       = azurerm_storage_account.this.name
}

output "share_name" {
  description = "Name of the Azure Files share for FSLogix profile containers."
  value       = azurerm_storage_share.profiles.name
}

output "profile_share_path" {
  description = "UNC path for the FSLogix profile share (e.g. \\\\<account>.file.core.windows.net\\profiles)."
  value       = "\\\\${azurerm_storage_account.this.name}.file.core.windows.net\\${azurerm_storage_share.profiles.name}"
}

output "private_endpoint_id" {
  description = "Resource ID of the Azure Files private endpoint."
  value       = azurerm_private_endpoint.this.id
}
