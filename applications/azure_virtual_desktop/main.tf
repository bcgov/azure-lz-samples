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
  resource_group_name                       = azurerm_resource_group.avd_rg.name
  location                                  = azurerm_resource_group.avd_rg.location
  tags                                      = var.tags
  host_pool_name                            = each.value.name
  friendly_name                             = each.value.friendly_name
  description                               = each.value.description
  public_network_access                     = each.value.public_network_access
  deployment_scope                          = each.value.deployment_scope
  management_type                           = each.value.management_type
  ring                                      = each.value.ring
  vm_template                               = each.value.vm_template
  allow_rdp_shortpath_with_private_link     = each.value.allow_rdp_shortpath_with_private_link
  direct_udp                                = each.value.direct_udp
  managed_private_udp                       = each.value.managed_private_udp
  public_udp                                = each.value.public_udp
  relay_udp                                 = each.value.relay_udp
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
  private_endpoints                         = each.value.private_endpoints

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
  private_endpoints             = local.workspace_private_endpoints[each.key]
  tags                          = var.tags
  log_analytics_workspace_id    = local.avd_log_analytics_workspace_id
  diagnostic_log_category_group = each.value.diagnostic_log_category_group
  enable_diagnostics            = length(var.log_analytics_workspaces) > 0
}

module "session_hosts" {
  for_each = local.session_host_instances
  source   = "./modules/session_host"

  depends_on = [
    module.host_pools,
    module.networking,
  ]

  resource_group_name                  = azurerm_resource_group.avd_rg.name
  location                             = azurerm_resource_group.avd_rg.location
  subnet_id                            = each.value.subnet_id
  host_pool_id                         = each.value.host_pool_id
  host_pool_registration_token         = each.value.host_pool_registration_token
  vm_name                              = each.value.vm_name
  computer_name                        = each.value.computer_name
  size                                 = each.value.size
  join_type                            = each.value.join_type
  admin_username                       = each.value.admin_username
  admin_password                       = each.value.admin_password
  license_type                         = each.value.license_type
  os_disk_storage_account_type         = each.value.os_disk_storage_account_type
  os_disk_size_gb                      = each.value.os_disk_size_gb
  diff_disk_settings                   = each.value.diff_disk_settings
  accelerated_networking_enabled       = each.value.accelerated_networking_enabled
  availability_zone                    = each.value.availability_zone
  enable_boot_diagnostics              = each.value.enable_boot_diagnostics
  boot_diagnostics_storage_account_uri = each.value.boot_diagnostics_storage_account_uri
  extensions_time_budget               = each.value.extensions_time_budget
  enable_integrity_monitoring          = each.value.enable_integrity_monitoring
  patch_mode                           = each.value.patch_mode
  enable_automatic_updates             = each.value.enable_automatic_updates
  provision_vm_agent                   = each.value.provision_vm_agent
  secure_boot_enabled                  = each.value.secure_boot_enabled
  vtpm_enabled                         = each.value.vtpm_enabled
  source_image_id                      = each.value.source_image_id
  source_image_reference               = each.value.source_image_reference
  vm_role_assignments                  = each.value.vm_role_assignments
  # Resolve share paths: prefer explicit per-group override, otherwise use the
  # root fslogix_storage module output (if the module is enabled).
  fslogix_profile_share_paths = each.value.fslogix_profile_share_paths != null ? each.value.fslogix_profile_share_paths : (
    var.fslogix_storage != null ? [module.fslogix_storage[0].profile_share_path] : []
  )
  tags = each.value.tags
}

# ---------------------------------------------------------------------------
# FSLogix profile storage
# Creates an Azure Files account with Entra Kerberos auth, a profiles share,
# a private endpoint, and RBAC for session host VM identities.
# ---------------------------------------------------------------------------
module "fslogix_storage" {
  count  = var.fslogix_storage != null ? 1 : 0
  source = "./modules/fslogix_storage"

  depends_on = [
    module.networking,
  ]

  name                       = var.fslogix_storage.name
  location                   = azurerm_resource_group.avd_rg.location
  resource_group_name        = azurerm_resource_group.avd_rg.name
  tags                       = var.tags
  account_tier               = var.fslogix_storage.account_tier
  account_replication_type   = var.fslogix_storage.account_replication_type
  share_name                 = var.fslogix_storage.share_name
  share_quota_gb             = var.fslogix_storage.share_quota_gb
  private_endpoint_subnet_id = contains(keys(var.subnets), var.fslogix_storage.private_endpoint_subnet_key) ? module.networking.subnet_ids[var.fslogix_storage.private_endpoint_subnet_key] : var.existing_subnet_ids[var.fslogix_storage.private_endpoint_subnet_key]

  # Only additional principals (e.g. user/group IDs) are passed here.
  # Session host VM identities are assigned separately below to avoid a
  # circular dependency (session_hosts → fslogix_storage for share path).
  smb_contributor_principal_ids = var.fslogix_storage.smb_contributor_principal_ids

  log_analytics_workspace_id    = local.avd_log_analytics_workspace_id
  enable_diagnostics            = length(var.log_analytics_workspaces) > 0
  diagnostic_log_category_group = var.fslogix_storage.diagnostic_log_category_group
}

# Storage File Data SMB Share Contributor for each session host VM identity.
# Kept separate from the fslogix_storage module to avoid a circular reference:
#   session_hosts depends on fslogix_storage (share path) but fslogix_storage
#   must not depend on session_hosts (principal IDs).
resource "azurerm_role_assignment" "fslogix_smb_session_hosts" {
  for_each = var.fslogix_storage != null ? local.session_host_instances : {}

  scope                = module.fslogix_storage[0].id
  role_definition_name = "Storage File Data SMB Share Contributor"
  principal_id         = module.session_hosts[each.key].principal_id

  depends_on = [
    module.fslogix_storage,
    module.session_hosts,
  ]
}

resource "azurerm_monitor_data_collection_rule" "session_hosts" {
  count = length(var.log_analytics_workspaces) > 0 && length(local.session_host_instances) > 0 ? 1 : 0

  name                = "dcr-${substr(replace(lower(var.resource_group_name), "_", "-"), 0, 50)}-avd-sh"
  resource_group_name = azurerm_resource_group.avd_rg.name
  location            = azurerm_resource_group.avd_rg.location
  kind                = "Windows"
  tags                = var.tags

  destinations {
    log_analytics {
      name                  = "law"
      workspace_resource_id = local.avd_log_analytics_workspace_id
    }
  }

  data_flow {
    streams      = ["Microsoft-Perf"]
    destinations = ["law"]
  }

  data_flow {
    streams      = ["Microsoft-Event"]
    destinations = ["law"]
  }

  data_sources {
    # ---------------------------------------------------------------------------
    # Performance counters required by the AVD Insights configuration workbook.
    # Source: https://learn.microsoft.com/en-us/azure/virtual-desktop/insights-costs
    # Split into two blocks because DCR requires a single sampling_frequency_in_seconds
    # per performance_counter block, and AVD Insights specifies 30s for most
    # counters and 60s for logical disk counters.
    # ---------------------------------------------------------------------------

    # 30-second counters: memory, physical disk, processor, terminal services,
    # user input delay, RemoteFX network
    performance_counter {
      name                          = "perf-avd-30s"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 30
      counter_specifiers = [
        "\\Memory(*)\\Available Mbytes",
        "\\Memory(*)\\Page Faults/sec",
        "\\Memory(*)\\Pages/sec",
        "\\Memory(*)\\% Committed Bytes In Use",
        "\\PhysicalDisk(*)\\Avg. Disk Queue Length",
        "\\PhysicalDisk(*)\\Avg. Disk sec/Read",
        "\\PhysicalDisk(*)\\Avg. Disk sec/Transfer",
        "\\PhysicalDisk(*)\\Avg. Disk sec/Write",
        "\\Processor Information(_Total)\\% Processor Time",
        "\\Terminal Services(*)\\Active Sessions",
        "\\Terminal Services(*)\\Inactive Sessions",
        "\\Terminal Services(*)\\Total Sessions",
        "\\User Input Delay per Process(*)\\Max Input Delay",
        "\\User Input Delay per Session(*)\\Max Input Delay",
        "\\RemoteFX Network(*)\\Current TCP RTT",
        "\\RemoteFX Network(*)\\Current UDP Bandwidth",
      ]
    }

    # 60-second counters: logical disk (drive-specific, as required by AVD Insights)
    performance_counter {
      name                          = "perf-avd-60s"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\LogicalDisk(C:)\\% Free Space",
        "\\LogicalDisk(C:)\\Avg. Disk Queue Length",
        "\\LogicalDisk(C:)\\Avg. Disk sec/Transfer",
        "\\LogicalDisk(C:)\\Current Disk Queue Length",
      ]
    }

    # ---------------------------------------------------------------------------
    # Windows Event Logs required by the AVD Insights configuration workbook.
    # All 6 channels collected at all levels (no severity filter) so the
    # workbook can render connection, session, and FSLogix events correctly.
    # ---------------------------------------------------------------------------
    windows_event_log {
      name    = "events-avd-insights"
      streams = ["Microsoft-Event"]
      x_path_queries = [
        "Application!*",
        "System!*",
        "Microsoft-Windows-TerminalServices-RemoteConnectionManager/Admin!*",
        "Microsoft-Windows-TerminalServices-LocalSessionManager/Operational!*",
        "Microsoft-FSLogix-Apps/Operational!*",
        "Microsoft-FSLogix-Apps/Admin!*",
      ]
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_monitor_data_collection_rule_association" "session_hosts" {
  for_each = length(var.log_analytics_workspaces) > 0 ? local.session_host_instances : {}

  name                    = "dcra-${replace(each.key, ".", "-")}"
  target_resource_id      = module.session_hosts[each.key].id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.session_hosts[0].id

  depends_on = [
    module.session_hosts,
  ]
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
  assignments                   = each.value.assignments
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

  log_analytics_workspace_id = local.avd_log_analytics_workspace_id
  enable_diagnostics         = length(var.log_analytics_workspaces) > 0
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "this" {
  for_each = local.workspace_application_group_associations

  workspace_id         = module.workspaces[each.value.workspace_key].id
  application_group_id = module.application_groups[each.value.application_group_key].id
}
