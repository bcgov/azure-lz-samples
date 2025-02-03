variable "version_control_system_organization_name" {
  description = "The name of the organization in the version control system."
  type        = string
}

variable "version_control_system_project_names" {
  description = "The names of the projects in the version control system."
  type        = list(string)
}

variable "managed_devops_pool_name" {
  description = "The name of the Managed DevOps Pool."
  type        = string
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
