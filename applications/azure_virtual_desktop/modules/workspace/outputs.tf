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
