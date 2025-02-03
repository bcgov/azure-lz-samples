# TO DO:
# - Registr the following Resource Providers:
#   - Microsoft.DevOpsInfrastructure
#   - Microsoft.DevCenter


resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

module "managed_devops_pool" {
  source  = "Azure/avm-res-devopsinfrastructure-pool/azurerm"
  version = "~> 0.2"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  version_control_system_organization_name = var.version_control_system_organization_name
  version_control_system_project_names     = var.version_control_system_project_names

  name                           = var.managed_devops_pool_name
  dev_center_project_resource_id = azurerm_dev_center_project.managed_devops_pool.id

  subnet_id = local.managed_devops_pool_subnet_id
}
