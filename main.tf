locals {
  # Fallback to an randomnly generated passwort, if no password is specified.
  administrator_password = (var.create_server && var.administrator_password == null
    ? random_password.this[0].result
  : var.administrator_password)
  server_id = var.create_server ? azurerm_postgresql_flexible_server.this[0].id : var.existing_server_id
}

# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
resource "random_password" "this" {
  count = var.create_server && var.administrator_password == null ? 1 : 0

  length           = 30
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
  min_lower        = 1
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret
#trivy:ignore:avd-azu-0017
resource "azurerm_key_vault_secret" "administrator_login" {
  count        = var.create_server ? 1 : 0
  name         = "${var.name}-administrator-login"
  content_type = "username"
  value        = azurerm_postgresql_flexible_server.this[0].administrator_login
  key_vault_id = var.key_vault_id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret
#trivy:ignore:avd-azu-0017
resource "azurerm_key_vault_secret" "administrator_login_password" {
  count        = var.create_server ? 1 : 0
  name         = "${var.name}-administrator-login-password"
  content_type = "password"
  value        = azurerm_postgresql_flexible_server.this[0].administrator_password
  key_vault_id = var.key_vault_id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server
resource "azurerm_postgresql_flexible_server" "this" {
  count = var.create_server ? 1 : 0

  name                              = var.name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  version                           = var.postgresql_version
  delegated_subnet_id               = var.delegated_subnet_id
  public_network_access_enabled     = var.delegated_subnet_id == null
  private_dns_zone_id               = var.private_dns_zone_id
  administrator_login               = var.administrator_login
  administrator_password            = local.administrator_password
  backup_retention_days             = var.backup_retention_days
  geo_redundant_backup_enabled      = var.geo_redundant_backup_enabled
  create_mode                       = var.create_mode
  point_in_time_restore_time_in_utc = var.point_in_time_restore_time_in_utc
  source_server_id                  = var.source_server_id
  zone                              = var.zone
  storage_mb                        = var.storage_mb
  sku_name                          = var.sku_name
  tags                              = var.tags

  authentication {
    active_directory_auth_enabled = var.active_directory_auth_enabled
    password_auth_enabled         = var.password_auth_enabled
    tenant_id                     = var.tenant_id
  }

  dynamic "maintenance_window" {
    for_each = var.enable_maintenance_window ? ["create_maintenance_window"] : []
    content {
      day_of_week  = var.day_of_week
      start_hour   = var.maintenance_start_hour
      start_minute = var.maintenance_start_minute
    }
  }
  lifecycle {
    ignore_changes = [
      # CDT:LANDINGZONE:TERRAGRUNT:HOOK:INSERT_IGNORED_TAGS
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_configuration
resource "azurerm_postgresql_flexible_server_configuration" "this" {
  count     = var.create_server && var.create_server_configuration ? 1 : 0
  name      = var.server_configuration_name
  server_id = azurerm_postgresql_flexible_server.this[0].id
  value     = var.server_configuration_value
  lifecycle {
    ignore_changes = [
      # CDT:LANDINGZONE:TERRAGRUNT:HOOK:INSERT_IGNORED_TAGS
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_firewall_rule
resource "azurerm_postgresql_flexible_server_firewall_rule" "this" {
  for_each         = { for rule in var.firewall_rules : rule.name => rule }
  name             = each.value.name
  server_id        = local.server_id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
  lifecycle {
    ignore_changes = [
      # CDT:LANDINGZONE:TERRAGRUNT:HOOK:INSERT_IGNORED_TAGS
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_diagnostic_categories
data "azurerm_monitor_diagnostic_categories" "server" {
  count       = var.create_server && var.enable_server_log_monitor_diagnostic ? 1 : 0
  resource_id = azurerm_postgresql_flexible_server.this[0].id
}

## Monitor Diagnostic Setting Locals
locals {
  all_true_server                        = var.enable_server_all_category_group_log && var.enable_server_audit_category_group_log && var.enable_server_custom_categories_log
  enable_server_all_category_group_logs  = (var.enable_server_all_category_group_log && !var.enable_server_audit_category_group_log && !var.enable_server_custom_categories_log) || local.all_true_server
  enable_server_audit_category_group_log = var.enable_server_audit_category_group_log && !var.enable_server_all_category_group_log && !var.enable_server_custom_categories_log
  enable_server_custom_categories_log    = var.enable_server_custom_categories_log && !var.enable_server_audit_category_group_log && !var.enable_server_all_category_group_log
}
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting
resource "azurerm_monitor_diagnostic_setting" "this" {
  count                          = var.create_server && var.enable_server_log_monitor_diagnostic ? 1 : 0
  name                           = "${var.name}-diagnostic-settings"
  target_resource_id             = azurerm_postgresql_flexible_server.this[0].id
  storage_account_id             = var.monitor_diagnostic_storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = var.log_analytics_destination_type
  partner_solution_id            = var.partner_solution_id

  dynamic "enabled_log" {
    for_each = local.enable_server_all_category_group_logs ? data.azurerm_monitor_diagnostic_categories.server[0].log_category_groups : toset([])
    content {
      category_group = enabled_log.value
    }
  }

  dynamic "enabled_log" {
    for_each = local.enable_server_custom_categories_log ? [true] : []
    content {
      category_group = toset(var.server_custom_log_categories)
    }
  }

  dynamic "enabled_log" {
    for_each = var.enable_server_audit_category_group_log ? [true] : []
    content {
      category_group = "audit"
    }
  }

  dynamic "metric" {
    for_each = var.enable_server_all_metrics ? [true] : []
    content {
      enabled  = var.enable_server_all_metrics
      category = join(",", data.azurerm_monitor_diagnostic_categories.server[0].metrics)
    }
  }
}

resource "time_sleep" "wait_60_seconds_after_server_creation" {
  depends_on = [azurerm_postgresql_flexible_server.this]

  create_duration = "60s"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_active_directory_administrator
resource "azurerm_postgresql_flexible_server_active_directory_administrator" "this" {
  depends_on = [time_sleep.wait_60_seconds_after_server_creation]

  for_each = { for k, v in var.active_directory_administrators : v.principal_name => v if var.create_server && var.active_directory_auth_enabled }

  server_name         = azurerm_postgresql_flexible_server.this[0].name
  resource_group_name = azurerm_postgresql_flexible_server.this[0].resource_group_name
  tenant_id           = azurerm_postgresql_flexible_server.this[0].authentication[0].tenant_id

  object_id      = each.value.object_id
  principal_name = each.value.principal_name
  principal_type = each.value.principal_type
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  for_each  = { for db in var.databases : db.name => db }
  name      = each.value.name
  server_id = local.server_id
  collation = each.value.collation
  charset   = each.value.charset
  lifecycle {
    ignore_changes = [
      # CDT:LANDINGZONE:TERRAGRUNT:HOOK:INSERT_IGNORED_TAGS
    ]
  }
}

# ----

locals {
  virtual_network_id    = one(regex("(.*?/virtualNetworks/[^/]+)", var.delegated_subnet_id))
  virtual_network_name  = one(regex("virtualNetworks/([^/]+)", var.delegated_subnet_id))
  private_dns_zone_name = var.private_dns_zone_id != null ? one(regex("privateDnsZones/([^/]+)", var.private_dns_zone_id)) : null
}


resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                = local.virtual_network_name
  resource_group_name = var.resource_group_name
  tags                = var.tags

  private_dns_zone_name = length(azurerm_private_dns_zone.this) > 0 ? azurerm_private_dns_zone.this[0].name : local.private_dns_zone_name
  virtual_network_id    = local.virtual_network_id
}


resource "azurerm_private_dns_zone" "this" {
  count               = var.create_private_link_dns_zone ? 1 : 0
  name                = "private.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
