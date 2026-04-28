# workspace

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
| [azurerm_virtual_desktop_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_workspace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | (Optional) Description for the workspace. | `string` | `null` | no |
| <a name="input_diagnostic_log_category_group"></a> [diagnostic\_log\_category\_group](#input\_diagnostic\_log\_category\_group) | (Optional) Diagnostic log category group. For AVD workspaces, this must be 'allLogs'. | `string` | `"allLogs"` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | (Optional) When true, diagnostic settings are created for the workspace. | `bool` | `false` | no |
| <a name="input_friendly_name"></a> [friendly\_name](#input\_friendly\_name) | (Optional) Friendly display name for the workspace. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure region for the workspace. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | (Optional) Log Analytics Workspace resource ID for diagnostic settings. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) Azure Virtual Desktop workspace name. | `string` | n/a | yes |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | (Optional) Whether public network access is enabled for the workspace. Defaults to false for policy-aligned private access. | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) Resource group name for the workspace. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to apply to the workspace. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_friendly_name"></a> [friendly\_name](#output\_friendly\_name) | Friendly name of the Azure Virtual Desktop workspace. |
| <a name="output_id"></a> [id](#output\_id) | Resource ID of the Azure Virtual Desktop workspace. |
| <a name="output_name"></a> [name](#output\_name) | Name of the Azure Virtual Desktop workspace. |
<!-- END_TF_DOCS -->
