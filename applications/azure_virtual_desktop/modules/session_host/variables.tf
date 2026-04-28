variable "resource_group_name" {
  description = "(Required) Resource group name for the session host VM."
  type        = string
}

variable "location" {
  description = "(Required) Azure region for the session host VM."
  type        = string
}

variable "subnet_id" {
  description = "(Required) Subnet ID where the session host NIC will be placed."
  type        = string
}

variable "host_pool_id" {
  description = "(Required) Host pool ID to which the session host belongs."
  type        = string
}

variable "host_pool_registration_token" {
  description = "(Required) Registration token used to register the VM with the AVD host pool."
  type        = string
  sensitive   = true
}

variable "vm_name" {
  description = "(Required) Azure VM name."
  type        = string
}

variable "computer_name" {
  description = "(Required) Windows computer name."
  type        = string
}

variable "size" {
  description = "(Required) Azure VM size for the session host."
  type        = string
}

variable "join_type" {
  description = "(Required) Session host join type. Currently only MicrosoftEntraJoined is supported."
  type        = string
}

variable "admin_username" {
  description = "(Required) Local administrator username for the session host."
  type        = string
}

variable "admin_password" {
  description = "(Optional) Local administrator password. When null, a strong password is generated."
  type        = string
  default     = null
  sensitive   = true
}

variable "license_type" {
  description = "(Optional) Windows license type for the session host VM."
  type        = string
  default     = "Windows_Client"
}

variable "os_disk_storage_account_type" {
  description = "(Optional) Storage account type for the OS disk."
  type        = string
  default     = "StandardSSD_LRS"
}

variable "patch_mode" {
  description = "(Optional) Windows patch mode for the session host VM."
  type        = string
  default     = "AutomaticByOS"
}

variable "enable_automatic_updates" {
  description = "(Optional) Whether automatic Windows updates are enabled."
  type        = bool
  default     = true
}

variable "provision_vm_agent" {
  description = "(Optional) Whether the Azure VM agent is provisioned."
  type        = bool
  default     = true
}

variable "secure_boot_enabled" {
  description = "(Optional) Whether secure boot is enabled."
  type        = bool
  default     = true
}

variable "vtpm_enabled" {
  description = "(Optional) Whether vTPM is enabled."
  type        = bool
  default     = true
}

variable "source_image_id" {
  description = "(Optional) Custom image ID for the session host VM."
  type        = string
  default     = null
}

variable "source_image_reference" {
  description = "(Optional) Marketplace image reference for the session host VM."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "office-365"
    sku       = "win11-24h2-avd-m365"
    version   = "latest"
  }
}

variable "vm_role_assignments" {
  description = "(Optional) Azure RBAC role assignments that control sign-in access to the VM."
  type = map(object({
    principal_id         = string
    principal_type       = optional(string)
    role_definition_name = optional(string, "Virtual Machine User Login")
  }))
  default = {}
}

variable "tags" {
  description = "(Optional) Tags to apply to the session host resources."
  type        = map(string)
  default     = {}
}
