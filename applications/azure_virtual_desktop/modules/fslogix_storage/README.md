# fslogix_storage

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
| [azapi_resource.diagnostics_file_service](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_update_resource.entra_kerberos](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/update_resource) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.smb_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_share.profiles](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_replication_type"></a> [account\_replication\_type](#input\_account\_replication\_type) | (Optional) Replication type for the storage account. LRS or ZRS are typical for FSLogix. Default: ZRS. | `string` | `"ZRS"` | no |
| <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier) | (Optional) Storage account tier. Premium is recommended for FSLogix (lower latency). Default: Premium. | `string` | `"Premium"` | no |
| <a name="input_diagnostic_log_category_group"></a> [diagnostic\_log\_category\_group](#input\_diagnostic\_log\_category\_group) | (Optional) Diagnostic log category group. Only allLogs is supported for storage accounts. | `string` | `"allLogs"` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | (Optional) When true and log\_analytics\_workspace\_id is non-null, diagnostic settings are created. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure region. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | (Optional) Log Analytics workspace resource ID for diagnostic settings. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) Storage account name. Must be globally unique, 3-24 lowercase alphanumeric characters. | `string` | n/a | yes |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | (Required) Subnet ID for the Azure Files private endpoint. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) Resource group for the storage account. | `string` | n/a | yes |
| <a name="input_share_name"></a> [share\_name](#input\_share\_name) | (Optional) Name of the Azure Files share for FSLogix profile containers. Default: profiles. | `string` | `"profiles"` | no |
| <a name="input_share_quota_gb"></a> [share\_quota\_gb](#input\_share\_quota\_gb) | (Optional) Capacity ceiling for the Azure Files share, in GiB. Default: 1024 GiB. | `number` | `1024` | no |
| <a name="input_smb_contributor_principal_ids"></a> [smb\_contributor\_principal\_ids](#input\_smb\_contributor\_principal\_ids) | (Optional) List of Entra principal IDs to assign Storage File Data SMB Share Contributor. Include session host VM managed identity principal IDs and optional user/group IDs. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to apply to all resources in this module. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Resource ID of the FSLogix storage account. |
| <a name="output_name"></a> [name](#output\_name) | Name of the FSLogix storage account. |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Resource ID of the Azure Files private endpoint. |
| <a name="output_profile_share_path"></a> [profile\_share\_path](#output\_profile\_share\_path) | UNC path for the FSLogix profile share (e.g. \\<account>.file.core.windows.net\profiles). |
| <a name="output_share_name"></a> [share\_name](#output\_share\_name) | Name of the Azure Files share for FSLogix profile containers. |
<!-- END_TF_DOCS -->
