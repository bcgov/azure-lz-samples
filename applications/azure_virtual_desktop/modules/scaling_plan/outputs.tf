output "scaling_plan_ids" {
  description = "Map of scaling plan keys to their resource IDs."
  value       = { for k, v in azapi_resource.scaling_plan : k => v.id }
}

output "scaling_plan_names" {
  description = "Map of scaling plan keys to their resource names."
  value       = { for k, v in azapi_resource.scaling_plan : k => v.name }
}
