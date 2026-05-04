output "existing_virtual_network_id" {
  value = data.azurerm_virtual_network.existing.id
}

output "existing_virtual_network_name" {
  value = data.azurerm_virtual_network.existing.name
}

output "network_security_group_ids" {
  value = module.networking.network_security_group_ids
}

output "subnet_ids" {
  value = module.networking.subnet_ids
}
