# How to use this module

## Prerequisites

To use this module, it is required to have the following:

- A Virtual Network (VNET)
- The following Resource Providers need to be registered in the target subscription:
  - Microsoft.App
  - Microsoft.ContainerInstance
  - Microsoft.ContainerRegistry
  - Microsoft.ContainerService
  - Microsoft.OperationalInsights
  - GitHub.Network

**Example Azure CLI:**

```cli
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.ContainerInstance
az provider register --namespace Microsoft.ContainerRegistry
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.OperationalInsights
az provider register --namespace GitHub.Network
```

> [!IMPORTANT]
> The Virtual Network (VNET) should be the **_existing_** VNet within the Subscription that was created as part of your Project Set (ie. `abc123-tools-vwan-spoke`). The required Subnets will be created by the module.

> [!NOTE]
> The `example.auto.tfvars` file will need to provide the appropriate **address_prefixes** for the subnets, based on the size required.
>
> The subnet for the **container app** requires a minimum size of `/27`.
>
> The subnet for the **container instance** requires a minimum size of `/28`.
>
> The subnet for the **private endpoint** has no minimum size requirement, and is not exclusive to the self-hosted runner solution.

## Usage

You must update the values in the `provider.tf` file, specifically the **backend** configuration. Please refer to the following Microsoft documentation about [Store Terraform state in Azure Storage](https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage).

> [!IMPORTANT]
> The Terraform state Storage Account is not created as part of this module. You must create this outside of this module, and provide the appropriate values in the `provider.tf` file. This Terraform state is **only** used for the self-hosted runners module, and is **not used** with/for any infrastructure that is deployed using the self-hosted runners.

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
subscription_id = "xxx" # This is the subscription ID where the resources will be created (ie. abc123-tools)

resource_group_name = "cicd-self-hosted-agents"
location            = "Canada Central"

postfix = "cicd"

version_control_system_type         = "github"
version_control_system_organization = "bcgov-c" # The organization name in the version control system
version_control_system_repository   = "REPO_NAME"
# export TF_VAR_github_personal_access_token=<your_github_personal_access_token>

virtual_network_resource_group = "VNET_RESOURCE_GROUP" # Existing Virtual Network Resource Group Name (ie. abc123-tools-networking)
virtual_network_name           = "VNET_NAME" # Existing Virtual Network Name (ie. abc123-tools-vwan-spoke)

container_app_subnet_name           = "SUBNET_NAME"
container_app_subnet_address_prefix = "1.2.3.4/27" # must be a minimum size of `/27`

container_instance_subnet_name           = "SUBNET_NAME"
container_instance_subnet_address_prefix = "1.2.3.4/28" # must be a minimum size of `/28`

private_endpoint_subnet_name           = "SUBNET_NAME"
private_endpoint_subnet_address_prefix = "1.2.3.4/28"

tags = { # NOTE: Add this to avoid removing tags that have been inherited from the resource group (on subsequent runs)
  account_coding = "000000000000000000000000"
  billing_group  = "abc123"
  ministry_name  = "MINISTRY_NAME"
}
```

## Post Deployment

Depending on the configuration used for the deployment, you may not see the self-hosted runners in the GitHub repository. This is because the Azure Container App `compute_types` are dynamically created on-demand (ie. ephemeral), and are also configured to scale to zero when not in use.

If you use the `azure_container_instance` `compute_types`, this will appear in the GitHub repository as a self-hosted runner immediately, as the instance will be running post-deployment.

## Known Issues

### IAM Role Assignment Error

When deploying the self-hosted runners, you may encounter the following error:

```shell
Error: authorization.RoleAssignmentsClient#Create: Failure responding to request: StatusCode=403 -- Original Error: autorest/azure: Service returned an error. Status=403 Code="AuthorizationFailed" Message="The client 'USER_NAME@gov.bc.ca' with object id 'xxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' does not have authorization to perform action 'Microsoft.Authorization/roleAssignments/write' over scope '/subscriptions/xxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/RESOURCE_GROUP_NAME/providers/Microsoft.ContainerRegistry/registries/CONTAINER_REGISTRY_NAME/providers/Microsoft.Authorization/roleAssignments/xxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' or the scope is invalid.
```

This is because the Managed Identity that is created (for the Container App Job) needs to be granted the `AcrPull` permission on the Azure Container Registry. If you have `Owner` permissions on the Subscription, you will not encounter this error.

### DNS Configuration

When deploying the self-hosted runners, the DNS configuration is added to the Azure Container Registry's Private Endpoint automatically by the Azure Policy applied to the Landing Zones. However, when subsequently running `terraform apply`, the DNS configuration will be removed.

It has been observed that despite the DNS configuration being removed on subsequent `terraform apply` runs, the DNS configuration is automatically re-added by the Azure Policy in the Landing Zones.

### Deleting Deployment

When deleting this deployment, if using the `azure_container_app` **Compute Type**, the Resource Group that is automatically created by the Azure Container App Service (ie. `RESOURCE_GROUP_NAME_container_app_infra`) is not deleted, even though `prevent_deletion_if_contains_resources = false` is set in the `provider.tf` file. You will need to manually delete this Resource Group.

### Other

Please refer to the official [terraform-azurerm-avm-ptn-cicd-agents-and-runners](https://github.com/Azure/terraform-azurerm-avm-ptn-cicd-agents-and-runners) GitHub repository for any known issues.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |
| <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) | ~> 0.3 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.5 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | 2.5.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.35.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_github_runners"></a> [github\_runners](#module\_github\_runners) | Azure/avm-ptn-cicd-agents-and-runners/azurerm | ~> 0.4 |

## Resources

| Name | Type |
|------|------|
| [azapi_resource.github_runners_container_app_subnet](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.github_runners_container_instance_subnet](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.github_runners_private_endpoint_subnet](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_network_security_group.github_runners_container_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.github_runners_container_instance](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.github_runners_private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compute_types"></a> [compute\_types](#input\_compute\_types) | (Optional) The types of compute to use. Allowed values are 'azure\_container\_app' and 'azure\_container\_instance'. | `set(string)` | <pre>[<br/>  "azure_container_app"<br/>]</pre> | no |
| <a name="input_container_app_subnet_address_prefix"></a> [container\_app\_subnet\_address\_prefix](#input\_container\_app\_subnet\_address\_prefix) | (Required) The address prefix for the container app subnet | `string` | n/a | yes |
| <a name="input_container_app_subnet_name"></a> [container\_app\_subnet\_name](#input\_container\_app\_subnet\_name) | (Required) The name of the existing subnet to use for the container app | `string` | n/a | yes |
| <a name="input_container_instance_count"></a> [container\_instance\_count](#input\_container\_instance\_count) | (Optional) The number of container instances to create | `number` | `2` | no |
| <a name="input_container_instance_subnet_address_prefix"></a> [container\_instance\_subnet\_address\_prefix](#input\_container\_instance\_subnet\_address\_prefix) | (Required) The address prefix for the container instance subnet | `string` | n/a | yes |
| <a name="input_container_instance_subnet_name"></a> [container\_instance\_subnet\_name](#input\_container\_instance\_subnet\_name) | (Required) The name of the existing subnet to use for the container instance | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | (Optional) Which Azure environment to deploy to. Options are: forge, or live. | `string` | `"live"` | no |
| <a name="input_existing_virtual_network_name"></a> [existing\_virtual\_network\_name](#input\_existing\_virtual\_network\_name) | (Required) The name of the existing virtual network | `string` | n/a | yes |
| <a name="input_existing_virtual_network_resource_group_name"></a> [existing\_virtual\_network\_resource\_group\_name](#input\_existing\_virtual\_network\_resource\_group\_name) | (Required) The name of the resource group containing the virtual network | `string` | n/a | yes |
| <a name="input_github_personal_access_token"></a> [github\_personal\_access\_token](#input\_github\_personal\_access\_token) | (Required) The PAT is used to generate a token to register the runner with GitHub. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure region to deploy to. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_postfix"></a> [postfix](#input\_postfix) | (Required) A postfix used to build default names if no name has been supplied for a specific resource type. | `string` | n/a | yes |
| <a name="input_private_endpoint_subnet_address_prefix"></a> [private\_endpoint\_subnet\_address\_prefix](#input\_private\_endpoint\_subnet\_address\_prefix) | (Required) The address prefix for the private endpoint subnet | `string` | n/a | yes |
| <a name="input_private_endpoint_subnet_name"></a> [private\_endpoint\_subnet\_name](#input\_private\_endpoint\_subnet\_name) | (Required) The name of the existing subnet for Private Endpoints | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the resource group in which to create the resources. | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | (Required) The Azure Subscription ID where the self-hosted runners will be deployed. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to the resources | `map(string)` | `null` | no |
| <a name="input_version_control_system_organization"></a> [version\_control\_system\_organization](#input\_version\_control\_system\_organization) | (Required) The organization of the version control system. | `string` | n/a | yes |
| <a name="input_version_control_system_repository"></a> [version\_control\_system\_repository](#input\_version\_control\_system\_repository) | (Required) The repository of the version control system. | `string` | n/a | yes |
| <a name="input_version_control_system_type"></a> [version\_control\_system\_type](#input\_version\_control\_system\_type) | (Optional) The type of version control system. | `string` | `"github"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ghrunners"></a> [ghrunners](#output\_ghrunners) | GitHub runners module outputs |
| <a name="output_github_runners_container_app_subnet"></a> [github\_runners\_container\_app\_subnet](#output\_github\_runners\_container\_app\_subnet) | GitHub runners container app subnet |
| <a name="output_github_runners_container_instance_subnet"></a> [github\_runners\_container\_instance\_subnet](#output\_github\_runners\_container\_instance\_subnet) | GitHub runners container instance subnet |
| <a name="output_github_runners_private_endpoint_subnet"></a> [github\_runners\_private\_endpoint\_subnet](#output\_github\_runners\_private\_endpoint\_subnet) | GitHub runners private endpoint subnet |
<!-- END_TF_DOCS -->
