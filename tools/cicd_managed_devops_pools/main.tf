resource "random_string" "random" {
  length      = 6
  lower       = true
  upper       = false
  special     = false
  numeric     = true
  min_numeric = 2
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

module "managed_devops_pool" {
  source  = "Azure/avm-res-devopsinfrastructure-pool/azurerm"
  version = "~> 0.2"

  depends_on = [
    azurerm_role_assignment.vnet_network_contributor,
    azapi_resource.managed_devops_pool_subnet
  ]

  resource_group_name = azurerm_resource_group.rg.name
  location            = local.virtual_network_location

  version_control_system_organization_name = var.version_control_system_organization_name
  version_control_system_project_names     = var.version_control_system_project_names
  role_assignments                         = local.role_assignments

  name                           = "${var.managed_devops_pool_name}-${random_string.random.result}"
  dev_center_project_resource_id = azurerm_dev_center_project.managed_devops_pool.id

  subnet_id = local.managed_devops_pool_subnet_id
}
