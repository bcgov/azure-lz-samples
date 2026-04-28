output "id" {
  description = "Resource ID of the session host VM."
  value       = azurerm_windows_virtual_machine.this.id
}

output "name" {
  description = "Name of the session host VM."
  value       = azurerm_windows_virtual_machine.this.name
}

output "computer_name" {
  description = "Windows computer name of the session host VM."
  value       = azurerm_windows_virtual_machine.this.computer_name
}

output "network_interface_id" {
  description = "Network interface ID for the session host VM."
  value       = azurerm_network_interface.this.id
}

output "private_ip_address" {
  description = "Primary private IP address of the session host VM."
  value       = azurerm_network_interface.this.private_ip_address
}

output "admin_username" {
  description = "Local administrator username for the session host VM."
  value       = azurerm_windows_virtual_machine.this.admin_username
}

output "admin_password" {
  description = "Sensitive local administrator password for the session host VM."
  value       = local.admin_password
  sensitive   = true
}

output "vm_role_assignment_ids" {
  description = "Role assignment IDs created for session host VM sign-in access."
  value       = { for key, value in azurerm_role_assignment.vm_login : key => value.id }
}
