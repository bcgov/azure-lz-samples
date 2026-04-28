# azure_virtual_desktop

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0, < 2.0.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 3.8.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.70.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_application_groups"></a> [application\_groups](#module\_application\_groups) | ./modules/application_group | n/a |
| <a name="module_host_pools"></a> [host\_pools](#module\_host\_pools) | ./modules/host_pool | n/a |
| <a name="module_key_vaults"></a> [key\_vaults](#module\_key\_vaults) | ./modules/key_vault | n/a |
| <a name="module_log_analytics_workspaces"></a> [log\_analytics\_workspaces](#module\_log\_analytics\_workspaces) | ./modules/log_analytics_workspace | n/a |
| <a name="module_networking"></a> [networking](#module\_networking) | ./modules/networking | n/a |
| <a name="module_scaling_plans"></a> [scaling\_plans](#module\_scaling\_plans) | ./modules/scaling_plan | n/a |
| <a name="module_workspaces"></a> [workspaces](#module\_workspaces) | ./modules/workspace | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.avd_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.avd_service_autoscale_subscription](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_virtual_desktop_workspace_application_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_workspace_application_group_association) | resource |
| [azuread_service_principal.azure_virtual_desktop](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_virtual_network.existing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_groups"></a> [application\_groups](#input\_application\_groups) | (Optional) Azure Virtual Desktop application groups to create and optionally associate with workspaces. | <pre>map(object({<br/>    name                          = string<br/>    type                          = string<br/>    host_pool_key                 = string<br/>    friendly_name                 = optional(string)<br/>    description                   = optional(string)<br/>    workspace_key                 = optional(string)<br/>    diagnostic_log_category_group = optional(string, "allLogs")<br/>  }))</pre> | `{}` | no |
| <a name="input_existing_network_security_group_ids"></a> [existing\_network\_security\_group\_ids](#input\_existing\_network\_security\_group\_ids) | (Optional) Map of pre-existing NSG resource IDs (key => id) to surface in networking outputs. | `map(string)` | `{}` | no |
| <a name="input_existing_subnet_ids"></a> [existing\_subnet\_ids](#input\_existing\_subnet\_ids) | (Optional) Map of pre-existing subnet resource IDs (key => id). Use this when a subnet required by this deployment already exists and should not be recreated. The key is referenced by Key Vault private\_endpoint\_subnet\_key. | `map(string)` | `{}` | no |
| <a name="input_host_pools"></a> [host\_pools](#input\_host\_pools) | (Optional) Map of Azure Virtual Desktop host pools to create. The map key is the stable Terraform identity, so ordering changes in tfvars do not cause false plan changes. | <pre>map(object({<br/>    name                             = string<br/>    friendly_name                    = optional(string)<br/>    description                      = optional(string)<br/>    host_pool_type                   = optional(string)<br/>    load_balancer_type               = optional(string)<br/>    personal_desktop_assignment_type = optional(string)<br/>    preferred_app_group_type         = optional(string)<br/>    max_session_limit                = optional(number)<br/>    start_vm_on_connect              = optional(bool)<br/>    validation_environment           = optional(bool)<br/>    custom_rdp_properties            = optional(string)<br/>    rdp_properties = optional(object({<br/>      entra_single_sign_on  = optional(bool) # enablerdsaadauth:i:1<br/>      auto_reconnection     = optional(bool) # autoreconnection enabled:i:1<br/>      bandwidth_auto_detect = optional(bool) # bandwidthautodetect:i:1<br/>      network_auto_detect   = optional(bool) # networkautodetect:i:1<br/>      bulk_compression      = optional(bool) # compression:i:1<br/>    }))<br/>    use_session_host_configuration  = optional(bool) # reserved: requires managementType=Automated; scaffold only<br/>    registration_token_operation    = optional(string)<br/>    registration_token_expiry_hours = optional(number)<br/>    agent_update = optional(object({<br/>      type                         = optional(string)<br/>      use_session_host_local_time  = optional(bool)<br/>      maintenance_window_time_zone = optional(string)<br/>      maintenance_windows = optional(list(object({<br/>        day_of_week = string<br/>        hour        = number<br/>      })))<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_key_vaults"></a> [key\_vaults](#input\_key\_vaults) | (Optional) Key Vaults to create. Each vault gets a private endpoint, optional AVD local-admin secrets, and optional diagnostic forwarding. | <pre>map(object({<br/>    name                       = string<br/>    sku_name                   = optional(string, "standard")<br/>    enable_rbac_authorization  = optional(bool, true)<br/>    purge_protection_enabled   = optional(bool, true)<br/>    soft_delete_retention_days = optional(number, 90)<br/>    avd_local_admin_username   = optional(string, "avdadmin")<br/>    create_local_admin_secrets = optional(bool, false)<br/>    # Key from networking subnet_ids (created or existing) used for the private endpoint.<br/>    private_endpoint_subnet_key   = string<br/>    diagnostic_log_category_group = optional(string, "audit")<br/>  }))</pre> | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure region to deploy to. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_log_analytics_workspaces"></a> [log\_analytics\_workspaces](#input\_log\_analytics\_workspaces) | (Optional) Log Analytics Workspaces to create. All other resources with diagnostics enabled will forward logs to the first workspace in this map unless a specific key is specified. | <pre>map(object({<br/>    name                          = string<br/>    sku                           = optional(string, "PerGB2018")<br/>    retention_in_days             = optional(number, 30)<br/>    daily_quota_gb                = optional(number, -1)<br/>    diagnostic_log_category_group = optional(string, "audit")<br/>  }))</pre> | `{}` | no |
| <a name="input_network_security_groups"></a> [network\_security\_groups](#input\_network\_security\_groups) | (Optional) Network security groups to create in the AVD resource group for later subnet attachment. | <pre>map(object({<br/>    name = string<br/>    security_rules = optional(map(object({<br/>      name                         = optional(string)<br/>      priority                     = number<br/>      direction                    = string<br/>      access                       = string<br/>      protocol                     = string<br/>      description                  = optional(string)<br/>      source_port_range            = optional(string)<br/>      source_port_ranges           = optional(list(string))<br/>      destination_port_range       = optional(string)<br/>      destination_port_ranges      = optional(list(string))<br/>      source_address_prefix        = optional(string)<br/>      source_address_prefixes      = optional(list(string))<br/>      destination_address_prefix   = optional(string)<br/>      destination_address_prefixes = optional(list(string))<br/>    })), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the resource group in which to create the resources. | `string` | n/a | yes |
| <a name="input_scaling_plans"></a> [scaling\_plans](#input\_scaling\_plans) | (Optional) Map of Azure Virtual Desktop scaling plans. Each plan references host pools by key from host\_pools. | <pre>map(object({<br/>    name           = string<br/>    friendly_name  = optional(string)<br/>    description    = optional(string)<br/>    host_pool_type = optional(string, "Pooled")<br/>    time_zone      = optional(string, "UTC")<br/>    host_pool_references = optional(list(object({<br/>      host_pool_key = string<br/>      enabled       = optional(bool, true)<br/>    })), [])<br/>    schedules = optional(list(any), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | (Optional) Subnets to create in the existing virtual network. A subnet can optionally attach to a created network security group using network\_security\_group\_key. | <pre>map(object({<br/>    name                                          = string<br/>    address_prefixes                              = list(string)<br/>    network_security_group_key                    = optional(string)<br/>    service_endpoints                             = optional(list(string), [])<br/>    delegation_name                               = optional(string)<br/>    delegation_service_name                       = optional(string)<br/>    private_endpoint_network_policies_enabled     = optional(bool, true)<br/>    private_link_service_network_policies_enabled = optional(bool, true)<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to the resources | `map(string)` | `null` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | (Required) The name of the existing virtual network used for Azure Virtual Desktop supporting resources. | `string` | n/a | yes |
| <a name="input_virtual_network_resource_group_name"></a> [virtual\_network\_resource\_group\_name](#input\_virtual\_network\_resource\_group\_name) | (Required) The name of the resource group containing the existing virtual network. | `string` | n/a | yes |
| <a name="input_workspaces"></a> [workspaces](#input\_workspaces) | (Optional) Azure Virtual Desktop workspaces to create. Application groups are associated using application\_groups[*].workspace\_key. | <pre>map(object({<br/>    name                          = string<br/>    friendly_name                 = optional(string)<br/>    description                   = optional(string)<br/>    public_network_access_enabled = optional(bool, false)<br/>    diagnostic_log_category_group = optional(string, "allLogs")<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_groups"></a> [application\_groups](#output\_application\_groups) | Map of Azure Virtual Desktop application groups keyed by var.application\_groups. |
| <a name="output_existing_virtual_network_id"></a> [existing\_virtual\_network\_id](#output\_existing\_virtual\_network\_id) | n/a |
| <a name="output_existing_virtual_network_name"></a> [existing\_virtual\_network\_name](#output\_existing\_virtual\_network\_name) | n/a |
| <a name="output_host_pool_registration_tokens"></a> [host\_pool\_registration\_tokens](#output\_host\_pool\_registration\_tokens) | n/a |
| <a name="output_host_pools"></a> [host\_pools](#output\_host\_pools) | n/a |
| <a name="output_key_vaults"></a> [key\_vaults](#output\_key\_vaults) | Map of Key Vault outputs keyed by the same keys used in var.key\_vaults. |
| <a name="output_log_analytics_workspace_primary_shared_keys"></a> [log\_analytics\_workspace\_primary\_shared\_keys](#output\_log\_analytics\_workspace\_primary\_shared\_keys) | Primary shared keys for all Log Analytics Workspaces. Sensitive. |
| <a name="output_log_analytics_workspaces"></a> [log\_analytics\_workspaces](#output\_log\_analytics\_workspaces) | Map of Log Analytics Workspace outputs keyed by the same keys used in var.log\_analytics\_workspaces. |
| <a name="output_network_security_group_ids"></a> [network\_security\_group\_ids](#output\_network\_security\_group\_ids) | n/a |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | n/a |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | n/a |
| <a name="output_scaling_plan_ids"></a> [scaling\_plan\_ids](#output\_scaling\_plan\_ids) | Map of scaling plan keys to resource IDs. |
| <a name="output_scaling_plan_names"></a> [scaling\_plan\_names](#output\_scaling\_plan\_names) | Map of scaling plan keys to resource names. |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | n/a |
| <a name="output_workspace_application_group_associations"></a> [workspace\_application\_group\_associations](#output\_workspace\_application\_group\_associations) | Map of workspace-to-application-group associations keyed by workspace\_key.application\_group\_key. |
| <a name="output_workspaces"></a> [workspaces](#output\_workspaces) | Map of Azure Virtual Desktop workspaces keyed by var.workspaces. |
<!-- END_TF_DOCS -->
