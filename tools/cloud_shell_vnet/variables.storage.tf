variable "storageAccountName" {
  description = "Name of the Storage Account"
  type        = string

  validation {
    condition     = length(var.storageAccountName) >=3 && length(var.storageAccountName) <= 24
    error_message = "The Storage Account name must be between 3 and 24 characters in length."
  }
}

variable "fileShareName" {
  description = "Name of the File Share"
  type        = string  
}
