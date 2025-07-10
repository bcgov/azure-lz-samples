variable "subscription_id" {
  description = "(Required) The Azure Subscription ID where the self-hosted runners will be deployed."
  type        = string
}

variable "environment" {
  description = "(Optional) Which Azure environment to deploy to. Options are: forge, or live."
  type        = string
  default     = "live" # NOTE: Do not change this unless instructed to by the Public Cloud team.
}

variable "location" {
  description = "(Required) Azure region to deploy to. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = contains(["canada central", "canadacentral", "canada east", "canadaeast"], lower(var.location))
    error_message = "ERROR: Only Canadian Azure Regions are allowed! Valid values for the variable \"location\" are: \"canadaeast\",\"canadacentral\"."
  }
}

variable "tags" {
  description = "(Optional) A map of tags to add to the resources"
  type        = map(string)
  default     = null
}
