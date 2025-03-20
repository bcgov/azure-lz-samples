# How to use this module

## Prerequisites

To use this module, it is required to have the following:

- An existing Azure DevOps organization that is connected to Microsoft Entra ID, and a Project within that organization
- A Virtual Network (VNET)
  - A subnet will be created with the information provided in the `example.auto.tfvars` file
- Check your subscription's [quotas](https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/prerequisites?view=azure-devops&tabs=azure-portal#review-managed-devops-pools-quotas) for the VM SKU you want to use
  - You may have to request a quota increase before you can create a managed DevOps pool
- The following Resource Providers must be [registered](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-providers-and-types#register-resource-provider-1) in the subscription:
  - Microsoft.DevOpsInfrastructure
  - Microsoft.DevCenter

> [!IMPORTANT]
> The Virtual Network (VNET) should be the **_existing_** VNet within the Subscription that was created as part of your Project Set (ie. `abc123-dev-vwan-spoke`). The subnet will be created within this VNet.

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
resource_group_name             = "managed-devops-pools"
location                        = "Canada Central"

virtual_network_resource_group = "abc123-dev-networking"
virtual_network_name            = "abc123-dev-vwan-spoke"
managed_devops_pool_subnet_name = "devops-pool"
managed_devops_pool_subnet_address_prefix = "10.41.0.0/28"

version_control_system_organization_name = "managed-pool-test" # Azure DevOps Organiation Name
version_control_system_project_names     = ["Managed Pool Project"] # Azure DevOps Project Names

dev_center_name                          = "managed-devops-pool"
dev_center_project_name                  = "managed-devops-pool"
dev_center_project_description           = "Managed DevOps Pool"
managed_devops_pool_name                 = "managed-devops-pool"
```

## Known Issues

Please refer to the official [terraform-azurerm-avm-res-devopsinfrastructure-pool](https://github.com/Azure/terraform-azurerm-avm-res-devopsinfrastructure-pool) GitHub repository for any known issues.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |
| <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) | ~> 0.3 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | 2.2.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.17.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_managed_devops_pool"></a> [managed\_devops\_pool](#module\_managed\_devops\_pool) | Azure/avm-res-devopsinfrastructure-pool/azurerm | ~> 0.2 |

## Resources

| Name | Type |
|------|------|
| [azapi_resource.managed_devops_pool_subnet](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_dev_center.managed_devops_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dev_center) | resource |
| [azurerm_dev_center_project.managed_devops_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dev_center_project) | resource |
| [azurerm_network_security_group.managed_devops_pool_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.vnet_network_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dev_center_name"></a> [dev\_center\_name](#input\_dev\_center\_name) | The name of the DevCenter. | `string` | n/a | yes |
| <a name="input_dev_center_project_description"></a> [dev\_center\_project\_description](#input\_dev\_center\_project\_description) | The description of the DevCenter Project. | `string` | `null` | no |
| <a name="input_dev_center_project_name"></a> [dev\_center\_project\_name](#input\_dev\_center\_project\_name) | The name of the DevCenter Project. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure region to deploy to. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_managed_devops_pool_name"></a> [managed\_devops\_pool\_name](#input\_managed\_devops\_pool\_name) | The name of the Managed DevOps Pool. | `string` | n/a | yes |
| <a name="input_managed_devops_pool_subnet_address_prefix"></a> [managed\_devops\_pool\_subnet\_address\_prefix](#input\_managed\_devops\_pool\_subnet\_address\_prefix) | The address prefix for the subnet to use for the Managed DevOps Pool | `string` | n/a | yes |
| <a name="input_managed_devops_pool_subnet_name"></a> [managed\_devops\_pool\_subnet\_name](#input\_managed\_devops\_pool\_subnet\_name) | The name of the existing subnet to use for the Managed DevOps Pool | `string` | n/a | yes |
| <a name="input_maximum_concurrency"></a> [maximum\_concurrency](#input\_maximum\_concurrency) | The maximum number of agents that can run concurrently, must be between 1 and 10000, defaults to 1. | `number` | `1` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the resource group in which to create the resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to the resources | `map(string)` | `null` | no |
| <a name="input_version_control_system_organization_name"></a> [version\_control\_system\_organization\_name](#input\_version\_control\_system\_organization\_name) | The name of the organization in the version control system. Corresponds to the https://dev.azure.com/ Organization name. | `string` | n/a | yes |
| <a name="input_version_control_system_project_names"></a> [version\_control\_system\_project\_names](#input\_version\_control\_system\_project\_names) | The names of the projects in the version control system. | `list(string)` | n/a | yes |
| <a name="input_version_control_system_type"></a> [version\_control\_system\_type](#input\_version\_control\_system\_type) | The type of the version control system. | `string` | `"azuredevops"` | no |
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
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the Resource Group. |
| <a name="output_virtual_network_location"></a> [virtual\_network\_location](#output\_virtual\_network\_location) | The location of the Virtual Network. |
<!-- END_TF_DOCS -->
