# key_vault

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | n/a |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.diagnostics](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_secret.avd_local_admin_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.avd_local_admin_username](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.deployer_secrets_officer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [random_password.avd_local_admin](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_avd_local_admin_username"></a> [avd\_local\_admin\_username](#input\_avd\_local\_admin\_username) | (Optional) Value stored in the AVD-Local-Admin-Username secret. Defaults to 'avdadmin'. | `string` | `"avdadmin"` | no |
| <a name="input_create_local_admin_secrets"></a> [create\_local\_admin\_secrets](#input\_create\_local\_admin\_secrets) | (Optional) When true, create AVD-Local-Admin-Username and AVD-Local-Admin-Password secrets in this vault. Keep false until Terraform runs from approved private connectivity. | `bool` | `false` | no |
| <a name="input_deployer_object_id"></a> [deployer\_object\_id](#input\_deployer\_object\_id) | (Required) Object ID of the principal running Terraform. Used to grant Key Vault Secrets Officer so secrets can be created when RBAC is enabled. | `string` | n/a | yes |
| <a name="input_diagnostic_log_category_group"></a> [diagnostic\_log\_category\_group](#input\_diagnostic\_log\_category\_group) | (Optional) Diagnostic log category group. Must be 'audit' or 'allLogs'. Defaults to 'audit'. | `string` | `"audit"` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | (Optional) When true, diagnostic settings are created. Must be true only when log\_analytics\_workspace\_id is also set. Separate bool keeps for\_each keys known at plan time. | `bool` | `false` | no |
| <a name="input_enable_rbac_authorization"></a> [enable\_rbac\_authorization](#input\_enable\_rbac\_authorization) | (Optional) Enable RBAC authorization for the Key Vault. Defaults to true. Note: argument will be renamed rbac\_authorization\_enabled in azurerm v5. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure region. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | (Optional) Log Analytics Workspace resource ID for diagnostic settings. When set, logs are forwarded to the workspace. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) Key Vault name. | `string` | n/a | yes |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | (Required) Resource ID of the subnet where the Key Vault private endpoint will be created. | `string` | n/a | yes |
| <a name="input_purge_protection_enabled"></a> [purge\_protection\_enabled](#input\_purge\_protection\_enabled) | (Optional) Enable purge protection. Defaults to true. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) Resource group name. | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | (Optional) SKU name. Must be 'standard' or 'premium'. Defaults to 'standard'. | `string` | `"standard"` | no |
| <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days) | (Optional) Soft-delete retention in days. Must be between 7 and 90. Defaults to 90. | `number` | `90` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to apply to the Key Vault and private endpoint. | `map(string)` | `null` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | (Required) Azure AD tenant ID for the Key Vault. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_avd_local_admin_password_secret_id"></a> [avd\_local\_admin\_password\_secret\_id](#output\_avd\_local\_admin\_password\_secret\_id) | Resource ID of the AVD-Local-Admin-Password secret, or null when create\_local\_admin\_secrets is false. |
| <a name="output_avd_local_admin_username_secret_id"></a> [avd\_local\_admin\_username\_secret\_id](#output\_avd\_local\_admin\_username\_secret\_id) | Resource ID of the AVD-Local-Admin-Username secret, or null when create\_local\_admin\_secrets is false. |
| <a name="output_id"></a> [id](#output\_id) | Resource ID of the Key Vault. |
| <a name="output_name"></a> [name](#output\_name) | Name of the Key Vault. |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Resource ID of the Key Vault private endpoint. |
| <a name="output_uri"></a> [uri](#output\_uri) | Vault URI of the Key Vault. |
<!-- END_TF_DOCS -->
