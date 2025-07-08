# How to use this module

## Prerequisites

To use this module, it is required to have the following:

- A Virtual Network (VNET)
- GitHub Enterprise Database ID
- The following Resource Providers need to be registered in the target subscription:
  - GitHub.Network

**Example Azure CLI:**

```cli
az provider register --namespace GitHub.Network
```

> [!IMPORTANT]
> The Virtual Network (VNET) should be the **_existing_** VNet within the Subscription that was created as part of your Project Set (ie. `abc123-tools-vwan-spoke`). The required Subnet will be created by the module.
> [!NOTE]
> The `example.auto.tfvars` file will need to provide the appropriate **address_prefixes** for the subnet, based on the size required.
>
> The subnet for the **GitHub Hosted Runners** has no minimum size requirement, and is dependent on the number of **GitHub hosted runners** that will be deployed.

## Usage

You must update the values in the `provider.tf` file, specifically the **backend** configuration. Please refer to the following Microsoft documentation about [Store Terraform state in Azure Storage](https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage).

> [!IMPORTANT]
> The Terraform state Storage Account is not created as part of this module. You must create this outside of this module, and provide the appropriate values in the `provider.tf` file. This Terraform state is **only** used for the infrastructure that is deployed using this module.

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
location            = "Canada Central"
existing_virtual_network_resource_group_name = "abc123-tools-networking" # Existing Virtual Network Resource Group Name
existing_virtual_network_name                = "abc123-tools-vwan-spoke" # Existing Virtual Network Name
github_hosted_runners_subnet_name           = "github-hosted-runners" # Name of the subnet to be created
github_hosted_runners_subnet_address_prefix = "10.41.4.64/28"
network_settings_name = "ghrs" # Name of the network settings resource
# export TF_VAR_github_organization_id=123456
tags = { # NOTE: Add this to avoid removing tags that have been inherited from the resource group (on subsequent runs)
  account_coding = "000000000000000000000000"
  billing_group  = "abc123"
  ministry_name  = "MINISTRY_NAME"
}
```

> [!IMPORTANT]
> You can use the [GitHub GraphQL Explorer](https://docs.github.com/en/enterprise-cloud@latest/graphql/overview/explorer) to find the **GitHub Database ID**. The following query can be used to find the ID:
> ```graphql
> query EnterpriseQuery($slug: String!) {
>   enterprise(slug: $slug) {
>     slug
>     databaseId
>   }
> }
> ```
>
> **Variables:**
> ```json
> {
>   "slug": "bcgov-enterprise"
> }
> ```

## Post Deployment
After the deployment is complete, a **Hosted compute networking** `Network Configuration` needs to be created in the GitHub Enterprise account. This needs to be completed by the DevEx team. They will require the **network settings resource ID** from the `Network Settings` resource created by this module.
Additionally, they will need to create a **Runner Group** and make that group available to the target **GitHub Organization**, along with adding the GitHub-hosted runners to the **Runner Group**.
Once the Runner Group is available to the GitHub Organization, an Organization Administrator can grant specific repositories access to the **Runner Group**. Only then will the GitHub-hosted runners appear in the **Settings** > **Actions** > **Runners** section of the repository (under the heading "Shared with this repository").

## Known Issues

### Network Settings

Once the Network Settings resource is created, it is not supported to update the GitHub Org ID. This is because the `BusinessID` property is immutable. If you attempt to update the GitHub Org ID, you will receive the following error: `The operation is not allowed. Attempt to modify immutable property 'BusinessId'`.
If you need to change the GitHub Org ID, you must destroy the Network Settings resource and re-create it.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | ~> 2.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.github_hosted_runners_network_settings](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.github_hosted_runners_subnet](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_network_security_group.github_hosted_runners_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.vnet_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | (Optional) Which Azure environment to deploy to. Options are: forge, or live. | `string` | `"live"` | no |
| <a name="input_existing_virtual_network_name"></a> [existing\_virtual\_network\_name](#input\_existing\_virtual\_network\_name) | (Required) The name of the existing virtual network | `string` | n/a | yes |
| <a name="input_existing_virtual_network_resource_group_name"></a> [existing\_virtual\_network\_resource\_group\_name](#input\_existing\_virtual\_network\_resource\_group\_name) | (Required) The name of the resource group containing the virtual network | `string` | n/a | yes |
| <a name="input_github_hosted_runners_subnet_address_prefix"></a> [github\_hosted\_runners\_subnet\_address\_prefix](#input\_github\_hosted\_runners\_subnet\_address\_prefix) | (Required) The address prefix for the GitHub hosted runners subnet | `string` | n/a | yes |
| <a name="input_github_hosted_runners_subnet_name"></a> [github\_hosted\_runners\_subnet\_name](#input\_github\_hosted\_runners\_subnet\_name) | (Required) The name of the existing subnet to use for the GitHub hosted runners | `string` | n/a | yes |
| <a name="input_github_organization_id"></a> [github\_organization\_id](#input\_github\_organization\_id) | (Required) The GitHub business (enterprise/organization) ID associated to the Azure subscription | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure region to deploy to. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_network_settings_name"></a> [network\_settings\_name](#input\_network\_settings\_name) | (Required) The name of the network settings resource | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | (Required) The Azure Subscription ID where the self-hosted runners will be deployed. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to the resources | `map(string)` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
