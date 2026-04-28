# networking

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | n/a |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.network_security_group_diagnostics](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.subnet](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | (Optional) When true, diagnostic settings are created for NSGs in this module. | `bool` | `false` | no |
| <a name="input_existing_network_security_group_ids"></a> [existing\_network\_security\_group\_ids](#input\_existing\_network\_security\_group\_ids) | (Optional) Map of pre-existing NSG resource IDs (key => id) to include in outputs alongside created NSGs. | `map(string)` | `{}` | no |
| <a name="input_existing_subnet_ids"></a> [existing\_subnet\_ids](#input\_existing\_subnet\_ids) | (Optional) Map of pre-existing subnet resource IDs (key => id) to include in outputs alongside created subnets. Use this when a required subnet was provisioned outside this module. | `map(string)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure region for created supporting resources. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | (Optional) Log Analytics Workspace resource ID for NSG diagnostic settings. | `string` | `null` | no |
| <a name="input_network_security_groups"></a> [network\_security\_groups](#input\_network\_security\_groups) | (Optional) Network security groups to create. | <pre>map(object({<br/>    name = string<br/>    security_rules = optional(map(object({<br/>      name                         = optional(string)<br/>      priority                     = number<br/>      direction                    = string<br/>      access                       = string<br/>      protocol                     = string<br/>      description                  = optional(string)<br/>      source_port_range            = optional(string)<br/>      source_port_ranges           = optional(list(string))<br/>      destination_port_range       = optional(string)<br/>      destination_port_ranges      = optional(list(string))<br/>      source_address_prefix        = optional(string)<br/>      source_address_prefixes      = optional(list(string))<br/>      destination_address_prefix   = optional(string)<br/>      destination_address_prefixes = optional(list(string))<br/>    })), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) Resource group for created supporting resources. | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | (Optional) Subnets to create in the existing virtual network. A subnet can optionally attach to a created network security group using network\_security\_group\_key. | <pre>map(object({<br/>    name                                          = string<br/>    address_prefixes                              = list(string)<br/>    network_security_group_key                    = optional(string)<br/>    service_endpoints                             = optional(list(string), [])<br/>    delegation_name                               = optional(string)<br/>    delegation_service_name                       = optional(string)<br/>    private_endpoint_network_policies_enabled     = optional(bool, true)<br/>    private_link_service_network_policies_enabled = optional(bool, true)<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to apply to created supporting resources. | `map(string)` | `null` | no |
| <a name="input_virtual_network_id"></a> [virtual\_network\_id](#input\_virtual\_network\_id) | (Required) Resource ID of the existing virtual network. | `string` | n/a | yes |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | (Required) Name of the existing virtual network. | `string` | n/a | yes |
| <a name="input_virtual_network_resource_group_name"></a> [virtual\_network\_resource\_group\_name](#input\_virtual\_network\_resource\_group\_name) | (Required) Resource group name of the existing virtual network. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_security_group_ids"></a> [network\_security\_group\_ids](#output\_network\_security\_group\_ids) | n/a |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | n/a |
| <a name="output_virtual_network_id"></a> [virtual\_network\_id](#output\_virtual\_network\_id) | n/a |
<!-- END_TF_DOCS -->
