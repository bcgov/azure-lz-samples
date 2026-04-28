resource "azurerm_resource_group" "avd_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

module "networking" {
  source = "./modules/networking"

  location                            = azurerm_resource_group.avd_rg.location
  resource_group_name                 = azurerm_resource_group.avd_rg.name
  tags                                = var.tags
  virtual_network_id                  = data.azurerm_virtual_network.existing.id
  virtual_network_name                = data.azurerm_virtual_network.existing.name
  virtual_network_resource_group_name = var.virtual_network_resource_group_name
  network_security_groups             = var.network_security_groups
  subnets                             = var.subnets
  existing_subnet_ids                 = var.existing_subnet_ids
  existing_network_security_group_ids = var.existing_network_security_group_ids
  log_analytics_workspace_id          = local.avd_log_analytics_workspace_id
  enable_diagnostics                  = length(var.log_analytics_workspaces) > 0
}

module "host_pools" {
  for_each = local.host_pools
  source   = "./modules/host_pool"

  depends_on = [
    module.log_analytics_workspaces,
    module.key_vaults,
    module.networking,
  ]

  resource_group_id                         = azurerm_resource_group.avd_rg.id
  location                                  = azurerm_resource_group.avd_rg.location
  tags                                      = var.tags
  host_pool_name                            = each.value.name
  friendly_name                             = each.value.friendly_name
  description                               = each.value.description
  host_pool_type                            = each.value.host_pool_type
  load_balancer_type                        = each.value.load_balancer_type
  personal_desktop_assignment_type          = each.value.personal_desktop_assignment_type
  preferred_app_group_type                  = each.value.preferred_app_group_type
  max_session_limit                         = each.value.max_session_limit
  start_vm_on_connect                       = each.value.start_vm_on_connect
  validation_environment                    = each.value.validation_environment
  custom_rdp_properties                     = each.value.custom_rdp_properties
  registration_token_operation              = each.value.registration_token_operation
  registration_token_expiry_hours           = each.value.registration_token_expiry_hours
  agent_update_type                         = each.value.agent_update.type
  agent_update_use_session_host_local_time  = each.value.agent_update.use_session_host_local_time
  agent_update_maintenance_window_time_zone = each.value.agent_update.maintenance_window_time_zone
  agent_update_maintenance_windows          = each.value.agent_update.maintenance_windows

  log_analytics_workspace_id = local.avd_log_analytics_workspace_id
  enable_diagnostics         = length(var.log_analytics_workspaces) > 0
}

module "log_analytics_workspaces" {
  for_each = var.log_analytics_workspaces
  source   = "./modules/log_analytics_workspace"

  name                          = each.value.name
  location                      = azurerm_resource_group.avd_rg.location
  resource_group_name           = azurerm_resource_group.avd_rg.name
  tags                          = var.tags
  sku                           = each.value.sku
  retention_in_days             = each.value.retention_in_days
  daily_quota_gb                = each.value.daily_quota_gb
  diagnostic_log_category_group = each.value.diagnostic_log_category_group
}

module "key_vaults" {
  for_each = var.key_vaults
  source   = "./modules/key_vault"

  name                          = each.value.name
  location                      = azurerm_resource_group.avd_rg.location
  resource_group_name           = azurerm_resource_group.avd_rg.name
  tags                          = var.tags
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  deployer_object_id            = data.azurerm_client_config.current.object_id
  sku_name                      = each.value.sku_name
  enable_rbac_authorization     = each.value.enable_rbac_authorization
  purge_protection_enabled      = each.value.purge_protection_enabled
  soft_delete_retention_days    = each.value.soft_delete_retention_days
  avd_local_admin_username      = each.value.avd_local_admin_username
  create_local_admin_secrets    = each.value.create_local_admin_secrets
  private_endpoint_subnet_id    = module.networking.subnet_ids[each.value.private_endpoint_subnet_key]
  log_analytics_workspace_id    = local.avd_log_analytics_workspace_id
  diagnostic_log_category_group = each.value.diagnostic_log_category_group
  enable_diagnostics            = length(var.log_analytics_workspaces) > 0
}

module "workspaces" {
  for_each = var.workspaces
  source   = "./modules/workspace"

  depends_on = [
    module.log_analytics_workspaces,
  ]

  name                          = each.value.name
  resource_group_name           = azurerm_resource_group.avd_rg.name
  location                      = azurerm_resource_group.avd_rg.location
  friendly_name                 = try(each.value.friendly_name, null)
  description                   = try(each.value.description, null)
  public_network_access_enabled = each.value.public_network_access_enabled
  tags                          = var.tags
  log_analytics_workspace_id    = local.avd_log_analytics_workspace_id
  diagnostic_log_category_group = each.value.diagnostic_log_category_group
  enable_diagnostics            = length(var.log_analytics_workspaces) > 0
}

module "application_groups" {
  for_each = var.application_groups
  source   = "./modules/application_group"

  depends_on = [
    module.host_pools,
    module.log_analytics_workspaces,
  ]

  name                          = each.value.name
  resource_group_name           = azurerm_resource_group.avd_rg.name
  location                      = azurerm_resource_group.avd_rg.location
  host_pool_id                  = module.host_pools[each.value.host_pool_key].id
  type                          = each.value.type
  friendly_name                 = try(each.value.friendly_name, null)
  description                   = try(each.value.description, null)
  tags                          = var.tags
  log_analytics_workspace_id    = local.avd_log_analytics_workspace_id
  diagnostic_log_category_group = each.value.diagnostic_log_category_group
  enable_diagnostics            = length(var.log_analytics_workspaces) > 0
}

resource "azurerm_role_assignment" "avd_service_autoscale_subscription" {
  for_each = length(var.scaling_plans) > 0 ? { enabled = true } : {}

  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Desktop Virtualization Power On Off Contributor"
  principal_id         = data.azuread_service_principal.azure_virtual_desktop.object_id
}

module "scaling_plans" {
  source = "./modules/scaling_plan"

  depends_on = [
    module.host_pools,
    azurerm_role_assignment.avd_service_autoscale_subscription,
  ]

  resource_group_id = azurerm_resource_group.avd_rg.id
  location          = azurerm_resource_group.avd_rg.location
  tags              = var.tags
  scaling_plans     = local.scaling_plans
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "this" {
  for_each = local.workspace_application_group_associations

  workspace_id         = module.workspaces[each.value.workspace_key].id
  application_group_id = module.application_groups[each.value.application_group_key].id
}
