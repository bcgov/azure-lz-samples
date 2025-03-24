output "ghrunners" {
  description = "GitHub runners module outputs"
  value       = module.github_runners
}

output "github_runners_container_app_subnet" {
  description = "GitHub runners container app subnet"
  value       = azapi_resource.github_runners_container_app_subnet
}

output "github_runners_container_instance_subnet" {
  description = "GitHub runners container instance subnet"
  value       = azapi_resource.github_runners_container_instance_subnet
}

output "github_runners_private_endpoint_subnet" {
  description = "GitHub runners private endpoint subnet"
  value       = azapi_resource.github_runners_private_endpoint_subnet
}
