# How to use this module

## Prerequisites

To use this module, it is required to have the following:

- A Virtual Network (VNET)
- Subscription ID for the `hashicorp/azurerm` provider (required when using v4.x)
  - See the `provider.tf` file for details

> NOTE: All other resources, including the Resource Group, "AzureBastionSubnet" Subnet, Network Security Groups (NSG) with required inbound/outbound rules, Public IP Address, and Bastion Host will be created by this module.

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
virtual_network_name           = "abc123-dev-vwan-spoke"
virtual_network_resource_group = "abc123-dev-networking"

resource_group_name        = "abc123-dev-bastion"
bastion_host_name          = "bastion" # NOTE: Will be appended with a random string
location                   = "canadacentral"
bastionSubnetAddressPrefix = "10.41.0.0/26"
```

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
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | 2.2.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.17.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azure_bastion"></a> [azure\_bastion](#module\_azure\_bastion) | Azure/avm-res-network-bastionhost/azurerm | n/a |

## Resources

| Name | Type |
|------|------|
| [azapi_resource.bastion_subnet](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_network_security_group.bastion_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.bastion_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.bastion_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastionSubnetAddressPrefix"></a> [bastionSubnetAddressPrefix](#input\_bastionSubnetAddressPrefix) | Address prefix for the bastion subnet. Must be at least w.x.y.z/26 | `string` | n/a | yes |
| <a name="input_bastion_host_name"></a> [bastion\_host\_name](#input\_bastion\_host\_name) | The name of the Bastion Host | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location/region where the Bastion Host should be created | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Bastion Host | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | <pre>{<br/>  "Environment": "Bastion"<br/>}</pre> | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | Name of the existing virtual network | `string` | n/a | yes |
| <a name="input_virtual_network_resource_group"></a> [virtual\_network\_resource\_group](#input\_virtual\_network\_resource\_group) | Name of the resource group containing the virtual network | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azure_bastion_name"></a> [azure\_bastion\_name](#output\_azure\_bastion\_name) | n/a |
| <a name="output_azurerm_public_ip_address"></a> [azurerm\_public\_ip\_address](#output\_azurerm\_public\_ip\_address) | n/a |
| <a name="output_azurerm_resource_group_name"></a> [azurerm\_resource\_group\_name](#output\_azurerm\_resource\_group\_name) | n/a |
<!-- END_TF_DOCS -->
