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
  value = module.github_runners
}
