output "resource_group_name" {
  value = azurerm_resource_group.bastion_rg.name
}

output "bastion" {
  value = module.azure_bastion
}

output "public_ip_address" {
  value = azurerm_public_ip.bastion_public_ip.ip_address
}
