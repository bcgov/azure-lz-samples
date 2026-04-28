output "id" {
  description = "Resource ID of the Azure Virtual Desktop workspace."
  value       = azurerm_virtual_desktop_workspace.this.id
}

output "name" {
  description = "Name of the Azure Virtual Desktop workspace."
  value       = azurerm_virtual_desktop_workspace.this.name
}

output "friendly_name" {
  description = "Friendly name of the Azure Virtual Desktop workspace."
  value       = azurerm_virtual_desktop_workspace.this.friendly_name
}

output "private_endpoint_ids" {
  description = "Private endpoint IDs created for the workspace."
  value       = { for key, value in azurerm_private_endpoint.this : key => value.id }
}
