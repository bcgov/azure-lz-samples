# How to use this module

## Prerequisites

To use this module, it is required to have the following:

- A Virtual Network (VNET)
- Subscription ID for the `hashicorp/azurerm` provider (required when using v4.x)
  - See the `provider.tf` file for details

> [!NOTE]
> All other resources, including the Resource Group, "**AzureBastionSubnet**" Subnet, Network Security Groups (NSG) with required inbound and outbound rules, Public IP Address, and Bastion Host will be created by this module.

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
virtual_network_name           = "abc123-dev-vwan-spoke"
virtual_network_resource_group = "abc123-dev-networking"

resource_group_name        = "abc123-dev-bastion"
bastion_host_name          = "bastion" # NOTE: Will be appended with a random string
location                   = "canadacentral"
bastionSubnetAddressPrefix = "10.41.0.0/26"

sku                = "Basic"
copy_paste_enabled = true # Configuration: Copy and paste

### Standard / Premium features:
# file_copy_enabled = true # Configuration: File transfer using a native client
# ip_connect_enabled = true # Configuration: IP-based connection
# kerberos_enabled = true # Configuration: Kerberos authentication
# scale_units = 4 # Configuration: Instance count
# shareable_link_enabled = true # Configuration: Shareable Link
# tunneling_enabled = true # Configuration: Native client support
# session_recording_enabled = true # Configuration: Session recording (Preview)
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
| <a name="input_bastion_host_name"></a> [bastion\_host\_name](#input\_bastion\_host\_name) | (Required) The name of the Bastion Host | `string` | n/a | yes |
| <a name="input_copy_paste_enabled"></a> [copy\_paste\_enabled](#input\_copy\_paste\_enabled) | (Optional) Is Copy/Paste feature enabled for the Bastion Host. Defaults to true. | `bool` | `true` | no |
| <a name="input_file_copy_enabled"></a> [file\_copy\_enabled](#input\_file\_copy\_enabled) | (Optional) Is File Copy feature enabled for the Bastion Host. Defaults to false. | `bool` | `null` | no |
| <a name="input_ip_connect_enabled"></a> [ip\_connect\_enabled](#input\_ip\_connect\_enabled) | (Optional) Is IP Connect feature enabled for the Bastion Host. Defaults to false. | `bool` | `null` | no |
| <a name="input_kerberos_enabled"></a> [kerberos\_enabled](#input\_kerberos\_enabled) | (Optional) Is Kerberos feature enabled for the Bastion Host. Defaults to false. | `bool` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The location/region where the Bastion Host should be created | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Bastion Host | `string` | n/a | yes |
| <a name="input_scale_units"></a> [scale\_units](#input\_scale\_units) | (Optional) The number of scale units for the Bastion Host. Defaults to 2. | `number` | `2` | no |
| <a name="input_session_recording_enabled"></a> [session\_recording\_enabled](#input\_session\_recording\_enabled) | (Optional) Enable session recording for the Bastion Host | `bool` | `null` | no |
| <a name="input_shareable_link_enabled"></a> [shareable\_link\_enabled](#input\_shareable\_link\_enabled) | (Optional) Is Shareable Link feature enabled for the Bastion Host. Defaults to false. | `bool` | `null` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | (Optional) Accepted values are Developer, Basic, Standard and Premium. | `string` | `"Basic"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | <pre>{<br/>  "Environment": "Bastion"<br/>}</pre> | no |
| <a name="input_tunneling_enabled"></a> [tunneling\_enabled](#input\_tunneling\_enabled) | (Optional) Enable tunneling through the Bastion Host | `bool` | `null` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | Name of the existing virtual network | `string` | n/a | yes |
| <a name="input_virtual_network_resource_group"></a> [virtual\_network\_resource\_group](#input\_virtual\_network\_resource\_group) | Name of the resource group containing the virtual network | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion"></a> [bastion](#output\_bastion) | n/a |
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | n/a |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | n/a |
<!-- END_TF_DOCS -->
