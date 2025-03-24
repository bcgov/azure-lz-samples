variable "version_control_system_type" {
  description = "(Optional) The type of version control system."
  type        = string
  default     = "github"
}

variable "version_control_system_organization" {
  description = "(Required) The organization of the version control system."
  type        = string
}

variable "version_control_system_repository" {
  description = "(Required) The repository of the version control system."
  type        = string
}

variable "github_personal_access_token" {
  description = "(Required) The PAT is used to generate a token to register the runner with GitHub."
  type        = string
  sensitive   = true
  # NOTE: Use export TF_VAR_github_personal_access_token=<your_github_personal_access_token>
}
