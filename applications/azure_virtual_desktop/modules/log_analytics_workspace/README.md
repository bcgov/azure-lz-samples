# log_analytics_workspace

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
| [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_daily_quota_gb"></a> [daily\_quota\_gb](#input\_daily\_quota\_gb) | (Optional) Daily ingestion quota in GB. Use -1 to disable the quota. Defaults to -1. | `number` | `-1` | no |
| <a name="input_diagnostic_log_category_group"></a> [diagnostic\_log\_category\_group](#input\_diagnostic\_log\_category\_group) | (Optional) Diagnostic log category group for self-diagnostics. Must be 'audit' or 'allLogs'. Defaults to 'audit'. | `string` | `"audit"` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure region. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) Log Analytics Workspace name. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) Resource group name. | `string` | n/a | yes |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | (Optional) Data retention in days. Must be between 7 and 730. Defaults to 30. | `number` | `30` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | (Optional) SKU. Defaults to PerGB2018. | `string` | `"PerGB2018"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to apply to the workspace. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Resource ID of the Log Analytics Workspace. |
| <a name="output_name"></a> [name](#output\_name) | Name of the Log Analytics Workspace. |
| <a name="output_primary_shared_key"></a> [primary\_shared\_key](#output\_primary\_shared\_key) | Primary shared key of the Log Analytics Workspace. |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | Workspace GUID of the Log Analytics Workspace (used by agents and monitoring extensions). |
<!-- END_TF_DOCS -->
