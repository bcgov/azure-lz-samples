output "virtualNetworkId" {
  value = data.azurerm_virtual_network.vnet.id
}

output "containerSubnetId" {
  value = azapi_resource.container_subnet.id
}

output "storageSubnetId" {
  value = azapi_resource.storage_subnet.id
}

output "networkSecurityGroupResourceId" {
  value = azurerm_network_security_group.container_nsg.id
}

output "nsgDefaultRules" {
  value = azurerm_network_security_group.container_nsg.security_rule
}
