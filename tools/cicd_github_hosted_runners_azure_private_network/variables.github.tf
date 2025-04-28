variable "github_organization_id" {
  description = "(Required) The GitHub business (enterprise/organization) ID associated to the Azure subscription"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.github_organization_id) > 0
    error_message = "The GitHub organization ID must not be empty."
  }
}
