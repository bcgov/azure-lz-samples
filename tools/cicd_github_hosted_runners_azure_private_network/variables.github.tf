# NOTE: Refer to the following documentation for guidance on how to find the GitHub organization ID (aka databaseId)
# https://docs.github.com/en/enterprise-cloud@latest/admin/configuring-settings/configuring-private-networking-for-hosted-compute-products/configuring-private-networking-for-github-hosted-runners-in-your-enterprise#1-obtain-the-databaseid-for-your-enterprise
variable "github_organization_id" {
  description = "(Required) The GitHub business (enterprise/organization) ID associated to the Azure subscription"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.github_organization_id) > 0
    error_message = "The GitHub organization ID must not be empty."
  }
}
