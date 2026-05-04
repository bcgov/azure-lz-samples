# scaling_plan

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.diagnostics](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.scaling_plan](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | (Optional) When true, diagnostic settings are created. Must be true only when log\_analytics\_workspace\_id is also set. Separate bool keeps for\_each keys known at plan time. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure region for the scaling plans. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | (Optional) Log Analytics Workspace resource ID for diagnostic settings. When set, AllLogs are forwarded to the workspace. | `string` | `null` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | (Required) Resource group ID where scaling plans are created. | `string` | n/a | yes |
| <a name="input_scaling_plans"></a> [scaling\_plans](#input\_scaling\_plans) | (Optional) Map of scaling plans to create. Each plan can reference one or more host pools. | <pre>map(object({<br/>    name                          = string<br/>    friendly_name                 = optional(string)<br/>    description                   = optional(string)<br/>    exclusion_tag                 = optional(string)<br/>    host_pool_type                = optional(string) # Pooled or Personal; defaults to Pooled<br/>    time_zone                     = optional(string) # IANA or Windows time zone; defaults to "UTC"<br/>    diagnostic_log_category_group = optional(string, "allLogs")<br/>    host_pool_references = optional(list(object({<br/>      host_pool_id = string<br/>      enabled      = optional(bool)<br/>    })), [])<br/>    schedules = optional(list(any), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to apply to scaling plan resources. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_scaling_plan_ids"></a> [scaling\_plan\_ids](#output\_scaling\_plan\_ids) | Map of scaling plan keys to their resource IDs. |
| <a name="output_scaling_plan_names"></a> [scaling\_plan\_names](#output\_scaling\_plan\_names) | Map of scaling plan keys to their resource names. |
<!-- END_TF_DOCS -->
