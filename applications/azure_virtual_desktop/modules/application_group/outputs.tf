output "id" {
  description = "Resource ID of the Azure Virtual Desktop application group."
  value       = azurerm_virtual_desktop_application_group.this.id
}

output "name" {
  description = "Name of the Azure Virtual Desktop application group."
  value       = azurerm_virtual_desktop_application_group.this.name
}

output "type" {
  description = "Type of the Azure Virtual Desktop application group."
  value       = azurerm_virtual_desktop_application_group.this.type
}

output "host_pool_id" {
  description = "Host pool ID associated with the Azure Virtual Desktop application group."
  value       = azurerm_virtual_desktop_application_group.this.host_pool_id
}
