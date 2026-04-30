# azure_virtual_desktop

## Overview

This module deploys an Azure Virtual Desktop environment into an existing hub-spoke or vWAN-connected virtual network. Two example configurations are provided:

| File | Access model | Host pool | Workspace feed |
|---|---|---|---|
| `example.public.tfvars` | Option 1 — public-capable | `Enabled` | Public (no private endpoint required) |
| `example.private.tfvars` | Option 2 — private-only | `Disabled` + private endpoint | Private endpoint only |

For drift-resistant public deployments, `example.public.tfvars` explicitly sets host pool `public_network_access = "Enabled"` and `load_balancer_type = "DepthFirst"`.

---

## Key Vault

Key Vault is **optional**. It is only needed if you want to store the session host local administrator credentials (`AVD-Local-Admin-Username` / `AVD-Local-Admin-Password`) as retrievable Key Vault secrets.

Omit the block entirely to skip Key Vault creation:

```hcl
key_vaults = {}
```

### `create_local_admin_secrets`

| Value | Behaviour |
|---|---|
| `false` (default) | The vault is provisioned but no secrets are written. The local admin password is auto-generated and stored only in Terraform state. The vault provides no active value. |
| `true` | Terraform writes `AVD-Local-Admin-Username` and `AVD-Local-Admin-Password` to the vault. **A private runner is required** (see below). |

### Private runner requirement

The vault is always deployed with `public_network_access_enabled = false`, regardless of the deployment option (public or private). When `create_local_admin_secrets = true`, Terraform must reach the vault's private endpoint to write secrets. This means:

- The pipeline **must** run from inside the private network — a self-hosted GitHub Actions runner, Azure DevOps self-hosted agent, or a Bastion-connected jump host.
- The runner must have private DNS resolution for `privatelink.vaultcore.azure.net` and network line-of-sight to the `avd_private_endpoints` subnet.
- Public GitHub-hosted runners (`ubuntu-latest`, etc.) will fail at secret creation with a network access error.

> In the **private-only** option (`example.private.tfvars`) this constraint extends to all Key Vault operations — there is no public fallback path for reads either.

### When is Key Vault justified?

- You require a break-glass / emergency-access path to VMs via local credentials outside of Entra ID.
- You want to rotate or audit the local admin password independently of Terraform state.

End-user AVD authentication uses Entra ID SSO (`enablerdsaadauth:i:1`) and does not depend on the local admin account.

---

## Connectivity Flows

The diagrams below describe the network paths for both access models. All session host egress is outbound only — no inbound ports are required on the session host NSG.

### End-user connectivity

**Option 1 — Public (`example.public.tfvars`)**

```
End-user (internet)
  │
  ├─► rdweb.wvd.microsoft.com (HTTPS 443)        # Workspace feed — global AVD gateway
  │     └─ Entra ID authentication
  │     └─ Returns list of published resources
  │
  ├─► rdbroker.wvd.microsoft.com (HTTPS 443)     # Session brokering — host pool lookup
  │     └─ Returns gateway token & session host assignment
  │
  └─► Azure RDP Gateway (TCP 443 / UDP 3478)     # Reverse-connect RDP tunnel
        └─ Session host (no inbound NSG rule needed)
```

The workspace feed is served publicly. The host pool `public_network_access = "Enabled"` allows clients to reach the broker endpoint without a private endpoint, while session host traffic still uses the reverse-connect gateway.

**Option 2 — Private (`example.private.tfvars`)**

```
End-user (corporate network / VPN / ExpressRoute)
  │
  ├─► Private DNS: *.wvd.microsoft.com → privatelink.wvd.microsoft.com
  │     └─ Resolves workspace and host pool FQDNs to private endpoint IPs
  │           in snet-avd-private-endpoints
  │
  ├─► Workspace private endpoint (subresource: feed)         # HTTPS 443, private IP
  │     └─ Entra ID authentication
  │     └─ Returns list of published resources
  │
  ├─► Host pool private endpoint (subresource: connection)   # HTTPS 443, private IP
  │     └─ Returns gateway token & session host assignment
  │
  └─► Azure RDP Gateway (TCP 443 / UDP 3478)                 # Reverse-connect tunnel
        └─ Session host (no inbound NSG rule needed)
```

> **DNS note**: Azure Policy (DINE) auto-creates the Private DNS Zone A-records for new private endpoints. This policy takes ~10 minutes to trigger after `terraform apply` completes. The AVD client and session host agent will both retry — no manual action is required, but the host pool may show the session host as **Unavailable** for up to ~10–15 minutes after a net-new deployment.

---

### AVD component connectivity (session host outbound)

The session host requires outbound HTTPS access to the following endpoints. All connections are initiated by the session host — no inbound rules are required.

| Destination | Port | Purpose |
|---|---|---|
| `*.wvd.microsoft.com` | TCP 443 | AVD agent registration and heartbeat to the AVD broker |
| `login.microsoftonline.com` | TCP 443 | Entra ID join and token acquisition |
| `*.login.microsoft.com` | TCP 443 | Entra ID SSO and authentication flows |
| `management.azure.com` | TCP 443 | Azure Resource Manager (extensions, run commands) |
| `*.blob.core.windows.net` | TCP 443 | Extension and agent package downloads |
| `go.microsoft.com` | TCP 443 | AVD agent MSI downloads during provisioning |
| `aka.ms` | TCP 443 | FSLogix installer download (redirects to blob) |
| FSLogix storage PE FQDN (`*.file.core.windows.net`) | TCP 445 | SMB profile container mounts via private endpoint |
| Key Vault PE FQDN (`*.vaultcore.azure.net`) | TCP 443 | Secret writes (only when `create_local_admin_secrets = true`) |
| Log Analytics ingestion endpoint | TCP 443 | DCR / AMA agent telemetry forwarding |

```
Session host (snet-avd-session-hosts)
  │
  ├─► AVD Broker  *.wvd.microsoft.com            (HTTPS — agent registration / heartbeat)
  ├─► Entra ID    login.microsoftonline.com       (HTTPS — join + SSO)
  ├─► ARM         management.azure.com            (HTTPS — extensions / run commands)
  ├─► Blob CDN    *.blob.core.windows.net         (HTTPS — agent + extension downloads)
  │
  ├─► Azure Files PE  stfslogix<suffix>.file.core.windows.net
  │     └─ snet-avd-private-endpoints : 10.x.x.x  (SMB 445 — FSLogix profile container)
  │
  ├─► Key Vault PE    kv-<name>.vaultcore.azure.net
  │     └─ snet-avd-private-endpoints : 10.x.x.x  (HTTPS 443 — only if create_local_admin_secrets = true)
  │
  └─► Log Analytics   <workspace>.ods.opinsights.azure.com
        └─ snet-avd-private-endpoints (if LAW PE configured) or internet  (HTTPS 443 — DCR / AMA)
```

---

---

## Deployment Timing

`terraform apply` completing successfully does **not** mean the environment is immediately ready for user connections. Several post-apply steps happen asynchronously on the session host VMs and the AVD control plane.

### Timeline after first `apply`

| Stage | Approximate elapsed time | What to observe |
|---|---|---|
| VM provisioned and extensions started | 0–5 min | VM shows `VM running` in Azure portal |
| AADLoginForWindows extension completes | 2–8 min | Extension status `Succeeded` |
| AVD agent installs and registers with host pool | 5–12 min | Session host appears in host pool with status `Unavailable`; `lastHeartBeat` timestamp is set; `sessionHostHealthCheckResults` is empty |
| AVD agent completes health checks | 10–20 min | `sessionHostHealthCheckResults` populates; status transitions to `Available` |
| FSLogix configuration applied via run command | Runs concurrently with above | No visible portal indicator; check run-command history on the VM |
| Environment ready for user login | **~15–25 min after apply** | Session host status = `Available` in host pool |

### How to verify readiness

```bash
# Show session host status (replace host pool / resource group names as appropriate)
az rest --method GET \
  --url "https://management.azure.com/subscriptions/<subscriptionId>/resourceGroups/<resourceGroup>/providers/Microsoft.DesktopVirtualization/hostPools/<hostPoolName>/sessionHosts/<vmName>?api-version=2024-08-08-preview" \
  --query "properties.{status:status, lastHeartBeat:lastHeartBeat, healthChecks:sessionHostHealthCheckResults}"
```

The session host is ready for connections when:
- `status` = `Available`
- `sessionHostHealthCheckResults` is non-empty (all checks passed)

### `Unavailable` with empty health check results

If the session host shows `Unavailable` and `sessionHostHealthCheckResults` is an empty array (`[]`), the AVD agent has registered but has not yet completed its initial health check cycle. This is **normal immediately after first deployment** — wait 5–10 minutes and re-query. No remediation is needed.

If the session host remains `Unavailable` for more than 30 minutes:
1. Connect to the VM via Azure Bastion and run `Get-Service RDAgentBootLoader, RDAgent` — both should be `Running`.
2. Check Event Viewer: `Applications and Services Logs > Microsoft > Windows > RemoteDesktopServices-RdpCoreTS`.
3. Verify that the registration token has not expired (tokens are valid for `registration_token_expiry_hours`, default 2 hours). Re-run `terraform apply` to rotate a fresh token if needed.

---

## Diagnostics

The `manage_diagnostic_settings` flag controls whether this module creates Azure Monitor diagnostic settings. Set it to `false` when an Azure Policy DINE assignment already deploys diagnostic settings in the target subscription to avoid resource conflicts on `apply`.

### Coverage per resource

| Resource | Has diagnostic settings | What is captured | Notes |
|---|---|---|---|
| Log Analytics Workspace | ✅ Yes | `audit` category group (default) | Logs to itself |
| NSG | ✅ Yes | `allLogs` (hardcoded) | One setting per NSG |
| Host Pool | ✅ Yes | `allLogs` | One setting per host pool |
| AVD Workspace | ✅ Yes | `allLogs` (default) | Configurable via `diagnostic_log_category_group` |
| Application Group | ✅ Yes | `allLogs` (default) | Configurable via `diagnostic_log_category_group` |
| Scaling Plan | ✅ Yes | `allLogs` | One setting per scaling plan |
| Key Vault | ✅ Yes | `audit` (default) | Configurable; sibling category explicitly disabled (see below) |
| FSLogix Storage Account | ✅ Yes | `Transaction` metric (account level) + `allLogs` logs (file service level) | Two settings: account-level metrics and file-service SMB access logs |
| Session host VM | ⚠️ Partial | Boot diagnostics (screenshot / serial log) | Full telemetry collected via DCR — see below |
| Network Interface | ❌ None | — | NICs do not produce meaningful diagnostic data for AVD scenarios |

### Session host monitoring (DCR)

When at least one session host is deployed and a Log Analytics Workspace exists, the root module automatically creates:

- **`azurerm_monitor_data_collection_rule`** — collects the AVD Insights performance counters (30 s and 60 s intervals) and Windows Event Log channels (`Application`, `System`, `TerminalServices-RemoteConnectionManager/Admin`, `TerminalServices-LocalSessionManager/Operational`, `FSLogix-Apps/Operational`, `FSLogix-Apps/Admin`) required by the AVD Insights workbook.
- **`azurerm_monitor_data_collection_rule_association`** — associates the rule with every session host VM.

This uses the Azure Monitor Agent (AMA) pipeline, which Microsoft recommends for new AVD deployments. The VM resource itself only has `boot_diagnostics` (screenshot / serial log) via the session host module — not a `Microsoft.Insights/diagnosticSettings` resource.

In addition, the root module creates **`azapi_resource.session_hosts_dcr_diagnostics`** when diagnostics are enabled so the Data Collection Rule resource itself emits diagnostic logs to the same Log Analytics Workspace.

### `allLogs` vs `audit` category groups

| Resource type | Supported groups | Module default |
|---|---|---|
| AVD resources (host pools, workspaces, app groups, scaling plans) | `allLogs` only | `allLogs` |
| Key Vault | `allLogs` and `audit` | `audit` |
| Log Analytics Workspace | `allLogs` and `audit` | `audit` |
| FSLogix Storage (file service) | `allLogs` only | `allLogs` |

`allLogs` captures all operational events including verbose activity; `audit` captures control-plane operations only. For Key Vault and Log Analytics Workspace, the module defaults to `audit` for cost efficiency and explicitly sets the sibling category to `enabled = false` to prevent the Azure portal from implicitly showing both as active.

---

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0, < 2.0.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | 2.9.0 |
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 3.8.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.70.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.8.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_application_groups"></a> [application\_groups](#module\_application\_groups) | ./modules/application_group | n/a |
| <a name="module_fslogix_storage"></a> [fslogix\_storage](#module\_fslogix\_storage) | ./modules/fslogix_storage | n/a |
| <a name="module_host_pools"></a> [host\_pools](#module\_host\_pools) | ./modules/host_pool | n/a |
| <a name="module_key_vaults"></a> [key\_vaults](#module\_key\_vaults) | ./modules/key_vault | n/a |
| <a name="module_log_analytics_workspaces"></a> [log\_analytics\_workspaces](#module\_log\_analytics\_workspaces) | ./modules/log_analytics_workspace | n/a |
| <a name="module_networking"></a> [networking](#module\_networking) | ./modules/networking | n/a |
| <a name="module_scaling_plans"></a> [scaling\_plans](#module\_scaling\_plans) | ./modules/scaling_plan | n/a |
| <a name="module_session_hosts"></a> [session\_hosts](#module\_session\_hosts) | ./modules/session_host | n/a |
| <a name="module_workspaces"></a> [workspaces](#module\_workspaces) | ./modules/workspace | n/a |

## Resources

| Name | Type |
|------|------|
| [azapi_resource.session_hosts_dcr_diagnostics](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_monitor_data_collection_rule.session_hosts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule) | resource |
| [azurerm_monitor_data_collection_rule_association.session_hosts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule_association) | resource |
| [azurerm_resource_group.avd_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.avd_service_autoscale_subscription](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.fslogix_smb_session_hosts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_virtual_desktop_workspace_application_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_workspace_application_group_association) | resource |
| [random_string.session_host_name_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azuread_service_principal.azure_virtual_desktop](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_virtual_network.existing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_groups"></a> [application\_groups](#input\_application\_groups) | (Optional) Azure Virtual Desktop application groups to create and optionally associate with workspaces. | <pre>map(object({<br/>    name                          = string<br/>    type                          = string<br/>    host_pool_key                 = string<br/>    friendly_name                 = optional(string)<br/>    description                   = optional(string)<br/>    workspace_key                 = optional(string)<br/>    diagnostic_log_category_group = optional(string, "allLogs")<br/>    assignments = optional(map(object({<br/>      principal_id         = string<br/>      principal_type       = optional(string)<br/>      role_definition_name = optional(string, "Desktop Virtualization User")<br/>    })), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_existing_network_security_group_ids"></a> [existing\_network\_security\_group\_ids](#input\_existing\_network\_security\_group\_ids) | (Optional) Map of pre-existing NSG resource IDs (key => id) to surface in networking outputs. | `map(string)` | `{}` | no |
| <a name="input_existing_subnet_ids"></a> [existing\_subnet\_ids](#input\_existing\_subnet\_ids) | (Optional) Map of pre-existing subnet resource IDs (key => id). Use this when a subnet required by this deployment already exists and should not be recreated. The key is referenced by Key Vault private\_endpoint\_subnet\_key. | `map(string)` | `{}` | no |
| <a name="input_fslogix_storage"></a> [fslogix\_storage](#input\_fslogix\_storage) | (Optional) FSLogix profile storage configuration. When set, an Azure Files account with Entra Kerberos authentication is provisioned and session hosts are configured to use it for profile containers. Leave null to skip FSLogix storage deployment. | <pre>object({<br/>    name                          = string # Storage account name (3-24 lowercase alphanumeric).<br/>    private_endpoint_subnet_key   = string # Key from subnets or existing_subnet_ids for the file private endpoint.<br/>    account_tier                  = optional(string, "Premium")<br/>    account_replication_type      = optional(string, "ZRS")<br/>    share_name                    = optional(string, "profiles")<br/>    share_quota_gb                = optional(number, 1024)<br/>    smb_contributor_principal_ids = optional(list(string), []) # Additional Entra principal IDs (users/groups).<br/>    diagnostic_log_category_group = optional(string, "allLogs")<br/>  })</pre> | `null` | no |
| <a name="input_host_pools"></a> [host\_pools](#input\_host\_pools) | (Optional) Map of Azure Virtual Desktop host pools to create. The map key is the stable Terraform identity, so ordering changes in tfvars do not cause false plan changes. | <pre>map(object({<br/>    name                                  = string<br/>    friendly_name                         = optional(string)<br/>    description                           = optional(string)<br/>    public_network_access                 = optional(string)<br/>    deployment_scope                      = optional(string)<br/>    management_type                       = optional(string)<br/>    ring                                  = optional(number)<br/>    vm_template                           = optional(string)<br/>    allow_rdp_shortpath_with_private_link = optional(string)<br/>    direct_udp                            = optional(string)<br/>    managed_private_udp                   = optional(string)<br/>    public_udp                            = optional(string)<br/>    relay_udp                             = optional(string)<br/>    host_pool_type                        = optional(string)<br/>    load_balancer_type                    = optional(string)<br/>    personal_desktop_assignment_type      = optional(string)<br/>    preferred_app_group_type              = optional(string)<br/>    max_session_limit                     = optional(number)<br/>    start_vm_on_connect                   = optional(bool)<br/>    validation_environment                = optional(bool)<br/>    custom_rdp_properties                 = optional(string)<br/>    rdp_properties = optional(object({<br/>      entra_single_sign_on  = optional(bool) # enablerdsaadauth:i:1<br/>      auto_reconnection     = optional(bool) # autoreconnection enabled:i:1<br/>      bandwidth_auto_detect = optional(bool) # bandwidthautodetect:i:1<br/>      network_auto_detect   = optional(bool) # networkautodetect:i:1<br/>      bulk_compression      = optional(bool) # compression:i:1<br/>      connections = optional(object({<br/>        credential_security_support_provider = optional(string) # Disabled, EnabledIfSupported<br/>      }))<br/>      session_behavior = optional(object({<br/>        video_playback_mode = optional(string) # Disabled, RdpEfficientWhenPossible<br/>      }))<br/>      device_redirection = optional(object({<br/>        audio_capture                             = optional(bool)   # audiocapturemode:i:0|1<br/>        audio_mode                                = optional(string) # PlayOnLocalDevice, PlayOnRemoteSession, DoNotPlay<br/>        cameras                                   = optional(string) # camerastoredirect:s:<value><br/>        devices                                   = optional(string) # devicestoredirect:s:<value><br/>        drives                                    = optional(string) # drivestoredirect:s:<value><br/>        encode_redirected_video_capture           = optional(bool)   # encode redirected video capture:i:0|1<br/>        keyboard_hook                             = optional(string) # Local, RemoteWhenInFocus, RemoteInFullScreen, RemoteAppWhenInFocus<br/>        redirect_clipboard                        = optional(bool)   # redirectclipboard:i:0|1<br/>        redirect_com_ports                        = optional(bool)   # redirectcomports:i:0|1<br/>        redirected_video_capture_encoding_quality = optional(string) # HighCompression, MediumCompression, LowCompressionHighQuality<br/>        redirect_location                         = optional(bool)   # redirectlocation:i:0|1<br/>        redirect_printers                         = optional(bool)   # redirectprinters:i:0|1<br/>        redirect_smart_cards                      = optional(bool)   # redirectsmartcards:i:0|1<br/>        redirect_webauthn                         = optional(bool)   # redirectwebauthn:i:0|1<br/>        usb_devices                               = optional(string) # usbdevicestoredirect:s:<value><br/>      }))<br/>      display_settings = optional(object({<br/>        desktop_size_id                 = optional(number) # desktop size id:i:0..4<br/>        desktop_height                  = optional(number) # desktopheight:i:200..8192<br/>        desktop_scale_factor            = optional(number) # desktopscalefactor:i:100|125|150|175|200|250|300|400|500<br/>        desktop_width                   = optional(number) # desktopwidth:i:200..8192<br/>        dynamic_resolution              = optional(bool)   # dynamic resolution:i:0|1<br/>        maximize_to_current_displays    = optional(bool)   # maximizetocurrentdisplays:i:0|1<br/>        screen_mode                     = optional(string) # Windowed, FullScreen<br/>        selected_monitors               = optional(string) # selectedmonitors:s:<value><br/>        single_monitor_in_windowed_mode = optional(bool)   # singlemoninwindowedmode:i:0|1<br/>        smart_sizing                    = optional(bool)   # smart sizing:i:0|1<br/>        use_multimon                    = optional(bool)   # use multimon:i:0|1<br/>      }))<br/>    }))<br/>    use_session_host_configuration  = optional(bool) # reserved: requires managementType=Automated; scaffold only<br/>    registration_token_operation    = optional(string)<br/>    registration_token_expiry_hours = optional(number)<br/>    agent_update = optional(object({<br/>      type                         = optional(string)<br/>      use_session_host_local_time  = optional(bool)<br/>      maintenance_window_time_zone = optional(string)<br/>      maintenance_windows = optional(list(object({<br/>        day_of_week = string<br/>        hour        = number<br/>      })))<br/>    }))<br/>    private_endpoints = optional(list(object({<br/>      subnet_key        = string<br/>      subresource_names = optional(list(string), ["connection"])<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_key_vaults"></a> [key\_vaults](#input\_key\_vaults) | (Optional) Key Vaults to create. Each vault gets a private endpoint, optional AVD local-admin secrets, and optional diagnostic forwarding. | <pre>map(object({<br/>    name                       = string<br/>    sku_name                   = optional(string, "standard")<br/>    enable_rbac_authorization  = optional(bool, true)<br/>    purge_protection_enabled   = optional(bool, true)<br/>    soft_delete_retention_days = optional(number, 90)<br/>    avd_local_admin_username   = optional(string, "avdadmin")<br/>    create_local_admin_secrets = optional(bool, false)<br/>    # Key from networking subnet_ids (created or existing) used for the private endpoint.<br/>    private_endpoint_subnet_key   = string<br/>    diagnostic_log_category_group = optional(string, "audit")<br/>  }))</pre> | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure region to deploy to. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_log_analytics_workspaces"></a> [log\_analytics\_workspaces](#input\_log\_analytics\_workspaces) | (Optional) Log Analytics Workspaces to create. All other resources with diagnostics enabled will forward logs to the first workspace in this map unless a specific key is specified. | <pre>map(object({<br/>    name                          = string<br/>    sku                           = optional(string, "PerGB2018")<br/>    retention_in_days             = optional(number, 30)<br/>    daily_quota_gb                = optional(number, -1)<br/>    diagnostic_log_category_group = optional(string, "audit")<br/>  }))</pre> | `{}` | no |
| <a name="input_manage_diagnostic_settings"></a> [manage\_diagnostic\_settings](#input\_manage\_diagnostic\_settings) | (Optional) When true, this module creates resource diagnostic settings. Set false when diagnostics are deployed by policy to avoid create/import conflicts. | `bool` | `true` | no |
| <a name="input_network_security_groups"></a> [network\_security\_groups](#input\_network\_security\_groups) | (Optional) Network security groups to create in the AVD resource group for later subnet attachment. | <pre>map(object({<br/>    name = string<br/>    security_rules = optional(map(object({<br/>      name                         = optional(string)<br/>      priority                     = number<br/>      direction                    = string<br/>      access                       = string<br/>      protocol                     = string<br/>      description                  = optional(string)<br/>      source_port_range            = optional(string)<br/>      source_port_ranges           = optional(list(string))<br/>      destination_port_range       = optional(string)<br/>      destination_port_ranges      = optional(list(string))<br/>      source_address_prefix        = optional(string)<br/>      source_address_prefixes      = optional(list(string))<br/>      destination_address_prefix   = optional(string)<br/>      destination_address_prefixes = optional(list(string))<br/>    })), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the resource group in which to create the resources. | `string` | n/a | yes |
| <a name="input_scaling_plans"></a> [scaling\_plans](#input\_scaling\_plans) | (Optional) Map of Azure Virtual Desktop scaling plans. Each plan references host pools by key from host\_pools. | <pre>map(object({<br/>    name                          = string<br/>    friendly_name                 = optional(string)<br/>    description                   = optional(string)<br/>    exclusion_tag                 = optional(string)<br/>    host_pool_type                = optional(string, "Pooled")<br/>    time_zone                     = optional(string, "UTC")<br/>    diagnostic_log_category_group = optional(string, "allLogs")<br/>    host_pool_references = optional(list(object({<br/>      host_pool_key = string<br/>      enabled       = optional(bool, true)<br/>    })), [])<br/>    schedules = optional(list(any), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_session_hosts"></a> [session\_hosts](#input\_session\_hosts) | (Optional) Map of Azure VM-based AVD session host definitions. Each entry can create one or more Microsoft Entra joined Windows session hosts and register them to a standard-management host pool. | <pre>map(object({<br/>    host_pool_key                = string<br/>    subnet_key                   = string<br/>    instance_count               = optional(number, 1)<br/>    vm_name_prefix               = optional(string)<br/>    computer_name_prefix         = optional(string)<br/>    random_name_suffix_enabled   = optional(bool, false)<br/>    random_name_suffix_length    = optional(number, 4)<br/>    size                         = optional(string, "Standard_D4ds_v4")<br/>    join_type                    = optional(string, "MicrosoftEntraJoined")<br/>    admin_username               = optional(string, "avdadmin")<br/>    admin_password               = optional(string)<br/>    license_type                 = optional(string, "Windows_Client")<br/>    os_disk_storage_account_type = optional(string, "StandardSSD_LRS")<br/>    os_disk_size_gb              = optional(number) # Override OS disk size in GB; leave null to use image default.<br/>    diff_disk_settings = optional(object({          # Ephemeral OS disk. Not compatible with os_disk_size_gb.<br/>      option    = string                            # CacheDisk or NvmeDisk<br/>      placement = optional(string)                  # CacheDisk or ResourceDisk<br/>    }))<br/>    accelerated_networking_enabled       = optional(bool, false)       # Requires a VM size that supports AN.<br/>    availability_zone                    = optional(number)            # 1, 2, or 3. Leave null to let Azure choose.<br/>    enable_boot_diagnostics              = optional(bool, true)        # Managed boot diagnostics by default.<br/>    boot_diagnostics_storage_account_uri = optional(string)            # Override with a specific storage account URI.<br/>    extensions_time_budget               = optional(string, "PT1H30M") # ISO 8601 duration budget for all extensions.<br/>    enable_integrity_monitoring          = optional(bool, true)        # Guest attestation integrity monitoring for Trusted Launch VMs.<br/>    patch_mode                           = optional(string, "AutomaticByOS")<br/>    enable_automatic_updates             = optional(bool, true)<br/>    provision_vm_agent                   = optional(bool, true)<br/>    secure_boot_enabled                  = optional(bool, true)<br/>    vtpm_enabled                         = optional(bool, true)<br/>    source_image_id                      = optional(string)<br/>    source_image_reference = optional(object({<br/>      publisher = string<br/>      offer     = string<br/>      sku       = string<br/>      version   = optional(string, "latest")<br/>    }))<br/>    vm_role_assignments = optional(map(object({<br/>      principal_id         = string<br/>      principal_type       = optional(string)<br/>      role_definition_name = optional(string, "Virtual Machine User Login")<br/>    })), {})<br/>    tags = optional(map(string), {})<br/>    # FSLogix: override profile share paths per session host group.<br/>    # When null, the root fslogix_storage module share path is used (if fslogix_storage is set).<br/>    fslogix_profile_share_paths = optional(list(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | (Optional) Subnets to create in the existing virtual network. A subnet can optionally attach to a created network security group using network\_security\_group\_key. | <pre>map(object({<br/>    name                                          = string<br/>    address_prefixes                              = list(string)<br/>    network_security_group_key                    = optional(string)<br/>    service_endpoints                             = optional(list(string), [])<br/>    delegation_name                               = optional(string)<br/>    delegation_service_name                       = optional(string)<br/>    private_endpoint_network_policies_enabled     = optional(bool, true)<br/>    private_link_service_network_policies_enabled = optional(bool, true)<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to the resources | `map(string)` | `null` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | (Required) The name of the existing virtual network used for Azure Virtual Desktop supporting resources. | `string` | n/a | yes |
| <a name="input_virtual_network_resource_group_name"></a> [virtual\_network\_resource\_group\_name](#input\_virtual\_network\_resource\_group\_name) | (Required) The name of the resource group containing the existing virtual network. | `string` | n/a | yes |
| <a name="input_workspaces"></a> [workspaces](#input\_workspaces) | (Optional) Azure Virtual Desktop workspaces to create. Application groups are associated using application\_groups[*].workspace\_key. | <pre>map(object({<br/>    name                          = string<br/>    friendly_name                 = optional(string)<br/>    description                   = optional(string)<br/>    public_network_access_enabled = optional(bool, false)<br/>    diagnostic_log_category_group = optional(string, "allLogs")<br/>    private_endpoints = optional(list(object({<br/>      subnet_key        = string<br/>      subresource_names = optional(list(string), ["feed"])<br/>    })), [])<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_groups"></a> [application\_groups](#output\_application\_groups) | Map of Azure Virtual Desktop application groups keyed by var.application\_groups. |
| <a name="output_existing_virtual_network_id"></a> [existing\_virtual\_network\_id](#output\_existing\_virtual\_network\_id) | n/a |
| <a name="output_existing_virtual_network_name"></a> [existing\_virtual\_network\_name](#output\_existing\_virtual\_network\_name) | n/a |
| <a name="output_host_pool_registration_tokens"></a> [host\_pool\_registration\_tokens](#output\_host\_pool\_registration\_tokens) | n/a |
| <a name="output_host_pools"></a> [host\_pools](#output\_host\_pools) | n/a |
| <a name="output_key_vaults"></a> [key\_vaults](#output\_key\_vaults) | Map of Key Vault outputs keyed by the same keys used in var.key\_vaults. |
| <a name="output_log_analytics_workspace_primary_shared_keys"></a> [log\_analytics\_workspace\_primary\_shared\_keys](#output\_log\_analytics\_workspace\_primary\_shared\_keys) | Primary shared keys for all Log Analytics Workspaces. Sensitive. |
| <a name="output_log_analytics_workspaces"></a> [log\_analytics\_workspaces](#output\_log\_analytics\_workspaces) | Map of Log Analytics Workspace outputs keyed by the same keys used in var.log\_analytics\_workspaces. |
| <a name="output_network_security_group_ids"></a> [network\_security\_group\_ids](#output\_network\_security\_group\_ids) | n/a |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | n/a |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | n/a |
| <a name="output_scaling_plan_ids"></a> [scaling\_plan\_ids](#output\_scaling\_plan\_ids) | Map of scaling plan keys to resource IDs. |
| <a name="output_scaling_plan_names"></a> [scaling\_plan\_names](#output\_scaling\_plan\_names) | Map of scaling plan keys to resource names. |
| <a name="output_session_host_admin_passwords"></a> [session\_host\_admin\_passwords](#output\_session\_host\_admin\_passwords) | Sensitive map of generated or supplied local administrator passwords for session hosts. |
| <a name="output_session_hosts"></a> [session\_hosts](#output\_session\_hosts) | Map of Azure VM-based AVD session hosts keyed by session\_hosts entry and instance number. |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | n/a |
| <a name="output_workspace_application_group_associations"></a> [workspace\_application\_group\_associations](#output\_workspace\_application\_group\_associations) | Map of workspace-to-application-group associations keyed by workspace\_key.application\_group\_key. |
| <a name="output_workspaces"></a> [workspaces](#output\_workspaces) | Map of Azure Virtual Desktop workspaces keyed by var.workspaces. |
<!-- END_TF_DOCS -->
