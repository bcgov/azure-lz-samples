# host_pool

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.host_pool](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.host_pool_diagnostics](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agent_update_maintenance_window_time_zone"></a> [agent\_update\_maintenance\_window\_time\_zone](#input\_agent\_update\_maintenance\_window\_time\_zone) | (Optional) Time zone for scheduled maintenance windows. | `string` | `null` | no |
| <a name="input_agent_update_maintenance_windows"></a> [agent\_update\_maintenance\_windows](#input\_agent\_update\_maintenance\_windows) | (Optional) Scheduled agent update maintenance windows. | <pre>list(object({<br/>    day_of_week = string<br/>    hour        = number<br/>  }))</pre> | `[]` | no |
| <a name="input_agent_update_type"></a> [agent\_update\_type](#input\_agent\_update\_type) | (Required) Agent update type. | `string` | n/a | yes |
| <a name="input_agent_update_use_session_host_local_time"></a> [agent\_update\_use\_session\_host\_local\_time](#input\_agent\_update\_use\_session\_host\_local\_time) | (Optional) Whether scheduled agent updates use the session host local time. | `bool` | n/a | yes |
| <a name="input_custom_rdp_properties"></a> [custom\_rdp\_properties](#input\_custom\_rdp\_properties) | (Optional) Custom RDP properties. | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) Description for the host pool. | `string` | `null` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | (Optional) When true, diagnostic settings are created. Must be true only when log\_analytics\_workspace\_id is also set. Separate bool keeps for\_each keys known at plan time. | `bool` | `false` | no |
| <a name="input_friendly_name"></a> [friendly\_name](#input\_friendly\_name) | (Optional) Friendly display name for the host pool. | `string` | `null` | no |
| <a name="input_host_pool_name"></a> [host\_pool\_name](#input\_host\_pool\_name) | (Required) Base host pool name before the random suffix is appended. | `string` | n/a | yes |
| <a name="input_host_pool_type"></a> [host\_pool\_type](#input\_host\_pool\_type) | (Required) Host pool type. | `string` | n/a | yes |
| <a name="input_load_balancer_type"></a> [load\_balancer\_type](#input\_load\_balancer\_type) | (Required) Load balancer type. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) The Azure region for the host pool. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | (Optional) Log Analytics Workspace resource ID for diagnostic settings. When set, AllLogs are forwarded to the workspace. | `string` | `null` | no |
| <a name="input_max_session_limit"></a> [max\_session\_limit](#input\_max\_session\_limit) | (Optional) Maximum number of sessions per session host. | `number` | `null` | no |
| <a name="input_personal_desktop_assignment_type"></a> [personal\_desktop\_assignment\_type](#input\_personal\_desktop\_assignment\_type) | (Optional) Personal desktop assignment type for Personal or BYODesktop pools. | `string` | `null` | no |
| <a name="input_preferred_app_group_type"></a> [preferred\_app\_group\_type](#input\_preferred\_app\_group\_type) | (Required) Preferred application group type. | `string` | n/a | yes |
| <a name="input_registration_token_expiry_hours"></a> [registration\_token\_expiry\_hours](#input\_registration\_token\_expiry\_hours) | (Required) Registration token expiration in hours. | `number` | n/a | yes |
| <a name="input_registration_token_operation"></a> [registration\_token\_operation](#input\_registration\_token\_operation) | (Required) Registration token operation. | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | (Required) The resource group ID where the host pool will be created. | `string` | n/a | yes |
| <a name="input_start_vm_on_connect"></a> [start\_vm\_on\_connect](#input\_start\_vm\_on\_connect) | (Optional) Enable Start VM on Connect. | `bool` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to apply to the host pool. | `map(string)` | `null` | no |
| <a name="input_validation_environment"></a> [validation\_environment](#input\_validation\_environment) | (Optional) Whether the host pool is a validation environment. | `bool` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_host_pool_type"></a> [host\_pool\_type](#output\_host\_pool\_type) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | Principal ID of the system-assigned managed identity on the host pool. Required for Start VM on Connect role assignments. |
| <a name="output_public_network_access"></a> [public\_network\_access](#output\_public\_network\_access) | n/a |
| <a name="output_registration_token"></a> [registration\_token](#output\_registration\_token) | n/a |
| <a name="output_resource_type"></a> [resource\_type](#output\_resource\_type) | n/a |
<!-- END_TF_DOCS -->
