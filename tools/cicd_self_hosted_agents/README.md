# How to use this module

## Preqrequisites

To use this module, it is required to have the following:

- A Virtual Network (VNET) with at least 3 subnets:
  - A subnet for the container app
    - Requires a minimum size of `/27` and be delegated to `Microsoft.App/environments`
  - A subnet for the container instance
    - Requires a minimum size of `/28` and be delegated to `Microsoft.ContainerInstance/containerGroups`
  - A subnet for the private endpoint
    - There is **no minimum size** required. Keep in mind that this subnet can be used for all Private Endpoints, and is not exclusive to the self-hosted runner solution.

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
resource_group_name = "cicd-self-hosted-agents"

tags = {
  account_coding = "000000000000000000000000",
  billing_group  = "LICENSE_PLATE",
  ministry_name  = "MINISTRY_NAME"
}

postfix = "cicd"

version_control_system_type         = "github"
version_control_system_organization = "bcgov-c" # The organization name in the version control system
version_control_system_repository   = "REPO_NAME"

virtual_network_resource_group = "VNET_RESOURCE_GROUP"
virtual_network_name           = "VNET_NAME"
container_app_subnet_name      = "SUBNET_NAME" # must be delegated to the service 'Microsoft.App/environments'
container_instance_subnet_name = "SUBNET_NAME" # must be delegated to the service 'Microsoft.ContainerInstance/containerGroups'
private_endpoint_subnet_name   = "SUBNET_NAME"
```

## Known Issues

Please refer to the official [terraform-azurerm-avm-ptn-cicd-agents-and-runners](https://github.com/Azure/terraform-azurerm-avm-ptn-cicd-agents-and-runners) GitHub repository for any known issues.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.113 |
| <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) | ~> 0.3 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.117.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_github_runners"></a> [github\_runners](#module\_github\_runners) | Azure/avm-ptn-cicd-agents-and-runners/azurerm | ~> 0.2.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compute_types"></a> [compute\_types](#input\_compute\_types) | The types of compute to use. Allowed values are 'azure\_container\_app' and 'azure\_container\_instance'. | `set(string)` | <pre>[<br/>  "azure_container_app"<br/>]</pre> | no |
| <a name="input_container_app_subnet_name"></a> [container\_app\_subnet\_name](#input\_container\_app\_subnet\_name) | The name of the existing subnet to use for the container app | `string` | n/a | yes |
| <a name="input_container_instance_count"></a> [container\_instance\_count](#input\_container\_instance\_count) | The number of container instances to create | `number` | `2` | no |
| <a name="input_container_instance_subnet_name"></a> [container\_instance\_subnet\_name](#input\_container\_instance\_subnet\_name) | The name of the existing subnet to use for the container instance | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Which Azure environment to deploy to. Options are: forge, or live. | `string` | `"live"` | no |
| <a name="input_github_personal_access_token"></a> [github\_personal\_access\_token](#input\_github\_personal\_access\_token) | The PAT is used to generate a token to register the runner with GitHub. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure region to deploy to. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_postfix"></a> [postfix](#input\_postfix) | A postfix used to build default names if no name has been supplied for a specific resource type. | `string` | n/a | yes |
| <a name="input_private_endpoint_subnet_name"></a> [private\_endpoint\_subnet\_name](#input\_private\_endpoint\_subnet\_name) | The name of the existing subnet for Private Endpoints | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the resource group in which to create the resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to the resources | `map(string)` | `null` | no |
| <a name="input_version_control_system_organization"></a> [version\_control\_system\_organization](#input\_version\_control\_system\_organization) | The organization of the version control system. | `string` | n/a | yes |
| <a name="input_version_control_system_repository"></a> [version\_control\_system\_repository](#input\_version\_control\_system\_repository) | The repository of the version control system. | `string` | n/a | yes |
| <a name="input_version_control_system_type"></a> [version\_control\_system\_type](#input\_version\_control\_system\_type) | The type of version control system. | `string` | `"github"` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the existing virtual network | `string` | n/a | yes |
| <a name="input_virtual_network_resource_group"></a> [virtual\_network\_resource\_group](#input\_virtual\_network\_resource\_group) | The name of the resource group containing the virtual network | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ghrunners"></a> [ghrunners](#output\_ghrunners) | n/a |
<!-- END_TF_DOCS -->
