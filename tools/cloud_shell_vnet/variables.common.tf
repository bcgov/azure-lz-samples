variable "resource_providers" {
  description = "The list of required Azure Resource Providers to register"
  type        = list(string)
  default = [
    "Microsoft.CloudShell",
    "Microsoft.ContainerInstance",
    "Microsoft.Relay"
  ]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    "Environment" = "cloudshell"
  }
}
