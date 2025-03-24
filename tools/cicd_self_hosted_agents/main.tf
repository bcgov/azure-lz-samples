resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

module "github_runners" {
  source  = "Azure/avm-ptn-cicd-agents-and-runners/azurerm"
  version = "~> 0.3"

  location = azurerm_resource_group.rg.location
  postfix  = var.postfix

  compute_types                                    = var.compute_types
  container_instance_count                         = var.container_instance_count
  container_app_infrastructure_resource_group_name = local.container_app_infrastructure_resource_group_name

  resource_group_creation_enabled = false
  resource_group_name             = azurerm_resource_group.rg.name

  version_control_system_type                  = var.version_control_system_type
  version_control_system_organization          = var.version_control_system_organization
  version_control_system_repository            = var.version_control_system_repository
  version_control_system_personal_access_token = var.github_personal_access_token

  virtual_network_creation_enabled = false
  virtual_network_id               = local.virtual_network_id

  container_app_subnet_id = azapi_resource.github_runners_container_app_subnet.id

  container_instance_subnet_id   = azapi_resource.github_runners_container_instance_subnet.id
  container_instance_subnet_name = var.container_instance_subnet_name

  container_registry_private_dns_zone_creation_enabled = false

  nat_gateway_creation_enabled = false
  public_ip_creation_enabled   = false

  container_registry_creation_enabled = true
  use_private_networking              = true
  use_default_container_image         = true

  container_registry_private_endpoint_subnet_id   = azapi_resource.github_runners_private_endpoint_subnet.id
  container_registry_private_endpoint_subnet_name = var.private_endpoint_subnet_name

  tags = var.tags
}
