variable "subscription_id" {
  description = "The Azure Subscription ID to use for the deployment."
  type        = string
}

variable "environment" {
  description = "Which Azure environment to deploy to. Options are: forge, or live."
  type        = string
  default     = "live"
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the resources."
  type        = string
}

variable "location" {
  description = "(Required) Azure region to deploy to. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = contains(["Canada Central", "canadacentral", "Canada East", "canadaeast"], var.location)
    error_message = "ERROR: Only Canadian Azure Regions are allowed! Valid values for the variable \"location\" are: \"canadaeast\",\"canadacentral\"."
  }
}

variable "postfix" {
  type        = string
  description = "A postfix used to build default names if no name has been supplied for a specific resource type."

  validation {
    condition     = length(var.postfix) <= 20
    error_message = "Variable 'postfix' must be less than 20 characters due to container app job naming restrictions. '${var.postfix}' is ${length(var.postfix)} characters."
  }
}

variable "tags" {
  description = "(Optional) A map of tags to add to the resources"
  type        = map(string)
  default     = null
}
