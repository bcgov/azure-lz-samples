# session_host

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_role_assignment.vm_login](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_virtual_machine_extension.aad_login](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.avd_registration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.integrity_monitoring](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_windows_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |
| [random_password.admin](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accelerated_networking_enabled"></a> [accelerated\_networking\_enabled](#input\_accelerated\_networking\_enabled) | (Optional) Whether accelerated networking is enabled on the NIC. Requires a VM size that supports it. | `bool` | `false` | no |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | (Optional) Local administrator password. When null, a strong password is generated. | `string` | `null` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | (Required) Local administrator username for the session host. | `string` | n/a | yes |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | (Optional) Availability zone number (1, 2, or 3) for the VM. Leave null to let Azure place the VM. | `number` | `null` | no |
| <a name="input_boot_diagnostics_storage_account_uri"></a> [boot\_diagnostics\_storage\_account\_uri](#input\_boot\_diagnostics\_storage\_account\_uri) | (Optional) Storage account blob endpoint for boot diagnostics. When null, managed boot diagnostics are enabled using an Azure-managed storage account. | `string` | `null` | no |
| <a name="input_computer_name"></a> [computer\_name](#input\_computer\_name) | (Required) Windows computer name. | `string` | n/a | yes |
| <a name="input_diff_disk_settings"></a> [diff\_disk\_settings](#input\_diff\_disk\_settings) | (Optional) Ephemeral OS disk settings. When set, the OS disk is placed on the VM cache or NVMe disk for lower latency. Not compatible with os\_disk\_size\_gb. | <pre>object({<br/>    option    = string           # CacheDisk or NvmeDisk<br/>    placement = optional(string) # CacheDisk or ResourceDisk<br/>  })</pre> | `null` | no |
| <a name="input_enable_automatic_updates"></a> [enable\_automatic\_updates](#input\_enable\_automatic\_updates) | (Optional) Whether automatic Windows updates are enabled. | `bool` | `true` | no |
| <a name="input_enable_boot_diagnostics"></a> [enable\_boot\_diagnostics](#input\_enable\_boot\_diagnostics) | (Optional) Whether boot diagnostics are enabled on the VM. | `bool` | `true` | no |
| <a name="input_enable_integrity_monitoring"></a> [enable\_integrity\_monitoring](#input\_enable\_integrity\_monitoring) | (Optional) Whether to enable guest attestation integrity monitoring on Trusted Launch session hosts. | `bool` | `true` | no |
| <a name="input_extensions_time_budget"></a> [extensions\_time\_budget](#input\_extensions\_time\_budget) | (Optional) Duration budget for all VM extensions, in ISO 8601 format (e.g. PT1H30M). | `string` | `"PT1H30M"` | no |
| <a name="input_host_pool_id"></a> [host\_pool\_id](#input\_host\_pool\_id) | (Required) Host pool ID to which the session host belongs. | `string` | n/a | yes |
| <a name="input_host_pool_registration_token"></a> [host\_pool\_registration\_token](#input\_host\_pool\_registration\_token) | (Required) Registration token used to register the VM with the AVD host pool. | `string` | n/a | yes |
| <a name="input_join_type"></a> [join\_type](#input\_join\_type) | (Required) Session host join type. Currently only MicrosoftEntraJoined is supported. | `string` | n/a | yes |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | (Optional) Windows license type for the session host VM. | `string` | `"Windows_Client"` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure region for the session host VM. | `string` | n/a | yes |
| <a name="input_os_disk_size_gb"></a> [os\_disk\_size\_gb](#input\_os\_disk\_size\_gb) | (Optional) OS disk size in GB. When null the image default is used. | `number` | `null` | no |
| <a name="input_os_disk_storage_account_type"></a> [os\_disk\_storage\_account\_type](#input\_os\_disk\_storage\_account\_type) | (Optional) Storage account type for the OS disk. | `string` | `"StandardSSD_LRS"` | no |
| <a name="input_patch_mode"></a> [patch\_mode](#input\_patch\_mode) | (Optional) Windows patch mode for the session host VM. | `string` | `"AutomaticByOS"` | no |
| <a name="input_provision_vm_agent"></a> [provision\_vm\_agent](#input\_provision\_vm\_agent) | (Optional) Whether the Azure VM agent is provisioned. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) Resource group name for the session host VM. | `string` | n/a | yes |
| <a name="input_secure_boot_enabled"></a> [secure\_boot\_enabled](#input\_secure\_boot\_enabled) | (Optional) Whether secure boot is enabled. | `bool` | `true` | no |
| <a name="input_size"></a> [size](#input\_size) | (Required) Azure VM size for the session host. | `string` | n/a | yes |
| <a name="input_source_image_id"></a> [source\_image\_id](#input\_source\_image\_id) | (Optional) Custom image ID for the session host VM. | `string` | `null` | no |
| <a name="input_source_image_reference"></a> [source\_image\_reference](#input\_source\_image\_reference) | (Optional) Marketplace image reference for the session host VM. | <pre>object({<br/>    publisher = string<br/>    offer     = string<br/>    sku       = string<br/>    version   = string<br/>  })</pre> | <pre>{<br/>  "offer": "office-365",<br/>  "publisher": "MicrosoftWindowsDesktop",<br/>  "sku": "win11-24h2-avd-m365",<br/>  "version": "latest"<br/>}</pre> | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | (Required) Subnet ID where the session host NIC will be placed. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to apply to the session host resources. | `map(string)` | `{}` | no |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | (Required) Azure VM name. | `string` | n/a | yes |
| <a name="input_vm_role_assignments"></a> [vm\_role\_assignments](#input\_vm\_role\_assignments) | (Optional) Azure RBAC role assignments that control sign-in access to the VM. | <pre>map(object({<br/>    principal_id         = string<br/>    principal_type       = optional(string)<br/>    role_definition_name = optional(string, "Virtual Machine User Login")<br/>  }))</pre> | `{}` | no |
| <a name="input_vtpm_enabled"></a> [vtpm\_enabled](#input\_vtpm\_enabled) | (Optional) Whether vTPM is enabled. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_password"></a> [admin\_password](#output\_admin\_password) | Sensitive local administrator password for the session host VM. |
| <a name="output_admin_username"></a> [admin\_username](#output\_admin\_username) | Local administrator username for the session host VM. |
| <a name="output_computer_name"></a> [computer\_name](#output\_computer\_name) | Windows computer name of the session host VM. |
| <a name="output_id"></a> [id](#output\_id) | Resource ID of the session host VM. |
| <a name="output_name"></a> [name](#output\_name) | Name of the session host VM. |
| <a name="output_network_interface_id"></a> [network\_interface\_id](#output\_network\_interface\_id) | Network interface ID for the session host VM. |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | Primary private IP address of the session host VM. |
| <a name="output_vm_role_assignment_ids"></a> [vm\_role\_assignment\_ids](#output\_vm\_role\_assignment\_ids) | Role assignment IDs created for session host VM sign-in access. |
<!-- END_TF_DOCS -->
