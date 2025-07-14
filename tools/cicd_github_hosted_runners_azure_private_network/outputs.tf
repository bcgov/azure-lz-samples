output "github_hosted_runners_subnet_name" {
  description = "The name of the GitHub hosted runners subnet"
  value       = azapi_resource.github_hosted_runners_subnet.name
}

output "github_hosted_runners_subnet_address_prefix" {
  description = "The address prefix of the GitHub hosted runners subnet"
  value       = azapi_resource.github_hosted_runners_subnet.body.properties.addressPrefix
}

output "github_hosted_runners_network_settings" {
  description = "The network settings resource"
  value       = azapi_resource.github_hosted_runners_network_settings
}
