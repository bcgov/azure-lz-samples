# application_group

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
| [azapi_resource.diagnostics](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_virtual_desktop_application_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_application_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | (Optional) Description for the application group. | `string` | `null` | no |
| <a name="input_diagnostic_log_category_group"></a> [diagnostic\_log\_category\_group](#input\_diagnostic\_log\_category\_group) | (Optional) Diagnostic log category group. Must be 'audit' or 'allLogs'. Defaults to 'allLogs'. | `string` | `"allLogs"` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | (Optional) When true, diagnostic settings are created for the application group. | `bool` | `false` | no |
| <a name="input_friendly_name"></a> [friendly\_name](#input\_friendly\_name) | (Optional) Friendly display name for the application group. | `string` | `null` | no |
| <a name="input_host_pool_id"></a> [host\_pool\_id](#input\_host\_pool\_id) | (Required) Host pool resource ID associated with the application group. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure region for the application group. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | (Optional) Log Analytics Workspace resource ID for diagnostic settings. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) Azure Virtual Desktop application group name. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) Resource group name for the application group. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to apply to the application group. | `map(string)` | `null` | no |
| <a name="input_type"></a> [type](#input\_type) | (Required) Application group type. Must be Desktop or RailApplications. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_host_pool_id"></a> [host\_pool\_id](#output\_host\_pool\_id) | Host pool ID associated with the Azure Virtual Desktop application group. |
| <a name="output_id"></a> [id](#output\_id) | Resource ID of the Azure Virtual Desktop application group. |
| <a name="output_name"></a> [name](#output\_name) | Name of the Azure Virtual Desktop application group. |
| <a name="output_type"></a> [type](#output\_type) | Type of the Azure Virtual Desktop application group. |
<!-- END_TF_DOCS -->
