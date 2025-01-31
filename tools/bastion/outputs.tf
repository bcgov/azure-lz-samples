output "azurerm_resource_group_name" {
  value = azurerm_resource_group.bastion_rg.name
}

output "azure_bastion_name" {
  value = module.azure_bastion.name
}

output "azurerm_public_ip_address" {
  value = azurerm_public_ip.bastion_public_ip.ip_address
}
