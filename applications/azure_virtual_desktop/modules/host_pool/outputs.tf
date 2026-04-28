output "id" {
  value = azapi_resource.host_pool.id
}

output "name" {
  value = azapi_resource.host_pool.name
}

output "resource_type" {
  value = azapi_resource.host_pool.type
}

output "host_pool_type" {
  value = azapi_resource.host_pool.output.properties.hostPoolType
}

output "public_network_access" {
  value = azapi_resource.host_pool.output.properties.publicNetworkAccess
}

output "registration_token" {
  value     = try(azapi_resource.host_pool.output.properties.registrationInfo.token, null)
  sensitive = true
}

output "principal_id" {
  description = "Principal ID of the system-assigned managed identity on the host pool. Required for Start VM on Connect role assignments."
  value       = try(azapi_resource.host_pool.identity[0].principal_id, null)
}

output "private_endpoint_ids" {
  description = "Private endpoint IDs created for the host pool."
  value       = { for key, value in azurerm_private_endpoint.this : key => value.id }
}
