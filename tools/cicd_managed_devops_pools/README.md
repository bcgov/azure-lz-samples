# How to use this module

## Prerequisites

To use this module, it is required to have the following:

- 

## Usage

You must update the values in the `provider.tf` file, specifically the **backend** configuration.

```terraform
backend "azurerm" {
  resource_group_name  = "tfstate"
  storage_account_name = "tfstate"
  container_name       = "tfstate"
  key                  = "terraform.tfstate"
}
```

You must update the values in the `example.auto.tfvars` file.

```terraform

```

## Known Issues

Please refer to the official [terraform-azurerm-avm-res-devopsinfrastructure-pool](https://github.com/Azure/terraform-azurerm-avm-res-devopsinfrastructure-pool) GitHub repository for any known issues.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.116 |
| <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) | ~> 0.3 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.116 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_managed_devops_pool"></a> [managed\_devops\_pool](#module\_managed\_devops\_pool) | Azure/avm-res-devopsinfrastructure-pool/azurerm | ~> 0.2 |

## Resources

| Name | Type |
|------|------|
| [azurerm_dev_center.managed_devops_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dev_center) | resource |
| [azurerm_dev_center_project.managed_devops_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dev_center_project) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dev_center_name"></a> [dev\_center\_name](#input\_dev\_center\_name) | The name of the DevCenter. | `string` | n/a | yes |
| <a name="input_dev_center_project_description"></a> [dev\_center\_project\_description](#input\_dev\_center\_project\_description) | The description of the DevCenter Project. | `string` | `null` | no |
| <a name="input_dev_center_project_name"></a> [dev\_center\_project\_name](#input\_dev\_center\_project\_name) | The name of the DevCenter Project. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Which Azure environment to deploy to. Options are: forge, or live. | `string` | `"live"` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure region to deploy to. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_managed_devops_pool_name"></a> [managed\_devops\_pool\_name](#input\_managed\_devops\_pool\_name) | The name of the Managed DevOps Pool. | `string` | n/a | yes |
| <a name="input_managed_devops_pool_subnet_name"></a> [managed\_devops\_pool\_subnet\_name](#input\_managed\_devops\_pool\_subnet\_name) | The name of the existing subnet to use for the Managed DevOps Pool | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the resource group in which to create the resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to the resources | `map(string)` | `null` | no |
| <a name="input_version_control_system_organization_name"></a> [version\_control\_system\_organization\_name](#input\_version\_control\_system\_organization\_name) | The name of the organization in the version control system. | `string` | n/a | yes |
| <a name="input_version_control_system_project_names"></a> [version\_control\_system\_project\_names](#input\_version\_control\_system\_project\_names) | The names of the projects in the version control system. | `list(string)` | n/a | yes |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the existing virtual network | `string` | n/a | yes |
| <a name="input_virtual_network_resource_group"></a> [virtual\_network\_resource\_group](#input\_virtual\_network\_resource\_group) | The name of the resource group containing the virtual network | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dev_center_id"></a> [dev\_center\_id](#output\_dev\_center\_id) | The ID of the DevCenter. |
| <a name="output_dev_center_project"></a> [dev\_center\_project](#output\_dev\_center\_project) | The DevCenter Project. |
| <a name="output_dev_center_project_id"></a> [dev\_center\_project\_id](#output\_dev\_center\_project\_id) | The ID of the DevCenter Project. |
| <a name="output_dev_center_uri"></a> [dev\_center\_uri](#output\_dev\_center\_uri) | The URI of the DevCenter. |
| <a name="output_managed_devops_pools"></a> [managed\_devops\_pools](#output\_managed\_devops\_pools) | n/a |
<!-- END_TF_DOCS -->
