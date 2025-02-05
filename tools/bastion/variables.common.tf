variable "resource_group_name" {
  description = "The name of the resource group in which to create the Bastion Host"
  type        = string
}

variable "location" {
  description = "The location/region where the Bastion Host should be created"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    "Environment" = "Bastion"
  }
}
