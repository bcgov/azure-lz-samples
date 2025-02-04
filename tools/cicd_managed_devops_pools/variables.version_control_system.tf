variable "version_control_system_organization_name" {
  description = "The name of the organization in the version control system. Corresponds to the https://dev.azure.com/ Organization name."
  type        = string
}

variable "version_control_system_type" {
  description = "The type of the version control system."
  type        = string
  default     = "azuredevops"
}

variable "version_control_system_project_names" {
  description = "The names of the projects in the version control system."
  type        = list(string)
}

variable "dev_center_name" {
  description = "The name of the DevCenter."
  type        = string
}

variable "dev_center_project_name" {
  description = "The name of the DevCenter Project."
  type        = string
}

variable "dev_center_project_description" {
  description = "The description of the DevCenter Project."
  type        = string
  default     = null
}

variable "managed_devops_pool_name" {
  description = "The name of the Managed DevOps Pool."
  type        = string
}

variable "maximum_concurrency" {
  description = "The maximum number of agents that can run concurrently, must be between 1 and 10000, defaults to 1."
  type        = number
  default     = 1
  # IMPORTANT: You must check your VM SKU quota in the region you are deploying to.

  validation {
    condition     = var.maximum_concurrency > 0 && var.maximum_concurrency <= 10000
    error_message = "The maximum concurrency must be between 1 and 10000."
  }
}
