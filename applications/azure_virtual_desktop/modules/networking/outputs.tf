output "virtual_network_id" {
  value = var.virtual_network_id
}

output "network_security_group_ids" {
  value = merge(
    { for key, nsg in azurerm_network_security_group.this : key => nsg.id },
    var.existing_network_security_group_ids
  )
}

output "subnet_ids" {
  value = merge(
    { for key, subnet in azapi_resource.subnet : key => subnet.id },
    var.existing_subnet_ids
  )
}
