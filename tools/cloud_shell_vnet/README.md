# cloud_shell_vnet

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
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.16.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.container_subnet](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.relay_subnet](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.storage_subnet](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_network_profile.cloudshell](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_profile) | resource |
| [azurerm_network_security_group.container_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.relay_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.storage_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_private_endpoint.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_relay_namespace.cloudshell](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/relay_namespace) | resource |
| [azurerm_role_assignment.network_profile](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.relay_namespace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.cloudshell](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_share.cloudshell_share](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_containerSubnetAddressPrefix"></a> [containerSubnetAddressPrefix](#input\_containerSubnetAddressPrefix) | Address prefix for the container subnet. | `string` | n/a | yes |
| <a name="input_containerSubnetName"></a> [containerSubnetName](#input\_containerSubnetName) | Name of the subnet to use for Cloud Shell containers. | `string` | `"cloudshellsubnet"` | no |
| <a name="input_fileShareName"></a> [fileShareName](#input\_fileShareName) | Name of the File Share | `string` | n/a | yes |
| <a name="input_privateEndpointName"></a> [privateEndpointName](#input\_privateEndpointName) | Name of Private Endpoint for Azure Relay. | `string` | `"cloudshellRelayEndpoint"` | no |
| <a name="input_relayNamespaceName"></a> [relayNamespaceName](#input\_relayNamespaceName) | Name of the Relay Namespace | `string` | n/a | yes |
| <a name="input_relaySubnetAddressPrefix"></a> [relaySubnetAddressPrefix](#input\_relaySubnetAddressPrefix) | Address prefix for the relay subnet. | `string` | n/a | yes |
| <a name="input_relaySubnetName"></a> [relaySubnetName](#input\_relaySubnetName) | Name of the subnet to use for Azure Relay. | `string` | `"relaysubnet"` | no |
| <a name="input_resource_providers"></a> [resource\_providers](#input\_resource\_providers) | The list of required Azure Resource Providers to register | `list(string)` | <pre>[<br/>  "Microsoft.CloudShell",<br/>  "Microsoft.ContainerInstance",<br/>  "Microsoft.Relay"<br/>]</pre> | no |
| <a name="input_storageAccountName"></a> [storageAccountName](#input\_storageAccountName) | Name of the Storage Account | `string` | n/a | yes |
| <a name="input_storageSubnetAddressPrefix"></a> [storageSubnetAddressPrefix](#input\_storageSubnetAddressPrefix) | Address prefix for the storage subnet. | `string` | n/a | yes |
| <a name="input_storageSubnetName"></a> [storageSubnetName](#input\_storageSubnetName) | Name of the subnet to use for storage. | `string` | `"storagesubnet"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | <pre>{<br/>  "Environment": "cloudshell"<br/>}</pre> | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | Name of the existing virtual network | `string` | n/a | yes |
| <a name="input_virtual_network_resource_group"></a> [virtual\_network\_resource\_group](#input\_virtual\_network\_resource\_group) | Name of the resource group containing the virtual network | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_containerSubnetId"></a> [containerSubnetId](#output\_containerSubnetId) | n/a |
| <a name="output_networkSecurityGroupResourceId"></a> [networkSecurityGroupResourceId](#output\_networkSecurityGroupResourceId) | n/a |
| <a name="output_nsgDefaultRules"></a> [nsgDefaultRules](#output\_nsgDefaultRules) | n/a |
| <a name="output_storageSubnetId"></a> [storageSubnetId](#output\_storageSubnetId) | n/a |
| <a name="output_virtualNetworkId"></a> [virtualNetworkId](#output\_virtualNetworkId) | n/a |
<!-- END_TF_DOCS -->
