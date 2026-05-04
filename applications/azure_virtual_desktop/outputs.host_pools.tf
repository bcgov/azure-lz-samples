output "host_pools" {
  value = {
    for key, host_pool in module.host_pools : key => {
      id                    = host_pool.id
      name                  = host_pool.name
      resource_type         = host_pool.resource_type
      host_pool_type        = host_pool.host_pool_type
      public_network_access = host_pool.public_network_access
      principal_id          = host_pool.principal_id
      private_endpoint_ids  = host_pool.private_endpoint_ids
    }
  }
}

output "host_pool_registration_tokens" {
  value = {
    for key, host_pool in module.host_pools : key => host_pool.registration_token
  }
  sensitive = true
}

output "scaling_plan_ids" {
  description = "Map of scaling plan keys to resource IDs."
  value       = module.scaling_plans.scaling_plan_ids
}

output "scaling_plan_names" {
  description = "Map of scaling plan keys to resource names."
  value       = module.scaling_plans.scaling_plan_names
}
