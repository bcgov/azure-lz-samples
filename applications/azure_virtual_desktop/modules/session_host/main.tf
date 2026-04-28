terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }

    random = {
      source = "hashicorp/random"
    }
  }
}

locals {
  admin_password = coalesce(var.admin_password, random_password.admin[0].result)

  registration_script = <<-EOT
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $agentInstaller = Join-Path $env:TEMP 'Microsoft.RDInfra.RDAgent.Installer-x64.msi'
    $bootLoaderInstaller = Join-Path $env:TEMP 'Microsoft.RDInfra.RDAgentBootLoader.Installer-x64.msi'
    Invoke-WebRequest -Uri 'https://go.microsoft.com/fwlink/?linkid=2310011' -OutFile $agentInstaller
    Invoke-WebRequest -Uri 'https://go.microsoft.com/fwlink/?linkid=2311028' -OutFile $bootLoaderInstaller
    Start-Process msiexec.exe -ArgumentList @('/i', $agentInstaller, '/quiet', '/qn', '/norestart', '/passive', 'REGISTRATIONTOKEN=${var.host_pool_registration_token}') -Wait -NoNewWindow
    Start-Process msiexec.exe -ArgumentList @('/i', $bootLoaderInstaller, '/quiet', '/qn', '/norestart', '/passive') -Wait -NoNewWindow
  EOT

  registration_command = format(
    "powershell.exe -ExecutionPolicy Bypass -EncodedCommand %s",
    textencodebase64(local.registration_script, "UTF-16LE")
  )
}

resource "random_password" "admin" {
  count = var.admin_password == null ? 1 : 0

  length           = 24
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  override_special = "!#$%&*()-_=+[]{}<>:?"
  special          = true
}

resource "azurerm_network_interface" "this" {
  name                = "nic-${var.vm_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.subnet_id
  }
}

resource "azurerm_windows_virtual_machine" "this" {
  name                = var.vm_name
  computer_name       = var.computer_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.size
  admin_username      = var.admin_username
  admin_password      = local.admin_password
  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]
  patch_mode               = var.patch_mode
  enable_automatic_updates = var.enable_automatic_updates
  provision_vm_agent       = var.provision_vm_agent
  license_type             = var.license_type
  secure_boot_enabled      = var.secure_boot_enabled
  vtpm_enabled             = var.vtpm_enabled
  source_image_id          = var.source_image_id
  tags                     = var.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_account_type
  }

  dynamic "source_image_reference" {
    for_each = var.source_image_id == null ? [var.source_image_reference] : []

    content {
      publisher = source_image_reference.value.publisher
      offer     = source_image_reference.value.offer
      sku       = source_image_reference.value.sku
      version   = source_image_reference.value.version
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_virtual_machine_extension" "aad_login" {
  count = var.join_type == "MicrosoftEntraJoined" ? 1 : 0

  name                       = "AADLogin"
  virtual_machine_id         = azurerm_windows_virtual_machine.this.id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  tags                       = var.tags
}

resource "azurerm_virtual_machine_extension" "avd_registration" {
  name                       = "AVDRegistration"
  virtual_machine_id         = azurerm_windows_virtual_machine.this.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true
  protected_settings = jsonencode({
    commandToExecute = local.registration_command
  })
  tags = var.tags

  depends_on = [
    azurerm_virtual_machine_extension.aad_login,
  ]

  lifecycle {
    ignore_changes = [protected_settings, settings, tags]
  }
}

resource "azurerm_role_assignment" "vm_login" {
  for_each = var.vm_role_assignments

  scope                = azurerm_windows_virtual_machine.this.id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
  principal_type       = try(each.value.principal_type, null)
}
