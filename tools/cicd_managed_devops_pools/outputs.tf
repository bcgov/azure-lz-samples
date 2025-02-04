output "resource_group_name" {
  description = "The name of the Resource Group."
  value       = azurerm_resource_group.rg.name
}

output "virtual_network_location" {
  description = "The location of the Virtual Network."
  value       = data.azurerm_virtual_network.vnet.location
}

output "dev_center_id" {
  description = "The ID of the DevCenter."
  value       = azurerm_dev_center.managed_devops_pool.id
}

output "dev_center_uri" {
  description = "The URI of the DevCenter."
  value       = azurerm_dev_center.managed_devops_pool.dev_center_uri
}

output "dev_center_project" {
  description = "The DevCenter Project."
  value       = azurerm_dev_center_project.managed_devops_pool
}

output "dev_center_project_id" {
  description = "The ID of the DevCenter Project."
  value       = azurerm_dev_center_project.managed_devops_pool.id
}

output "managed_devops_pools" {
  value = module.managed_devops_pool
}
