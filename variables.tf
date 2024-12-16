variable "active_directory_administrators" {
  description = <<-EOD
    A list of Active Directory objects (user, service principal or security group) designated as administrators for the PostgreSQL server.

    See [azurerm_postgresql_flexible_server_active_directory_administrator](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_active_directory_administrator) for a details.
    - `object_id` - (Required) The object ID of a user, service principal or security group in the Azure Active Directory tenant set as the Server Admin.
    - `principal_name` - (Required) The name of Azure Active Directory principal. Changing this forces a new resource to be created.
    - `principal_type` - (Required) The type of Azure Active Directory principal. Possible values are `Group`, `ServicePrincipal` and `User`.

    **NOTE**: This list is only considered when `active_directory_auth_enabled` is set to `true`.
  EOD
  default     = []
  type = list(object({
    object_id      = string
    principal_name = string
    principal_type = string
  }))
}

variable "active_directory_auth_enabled" {
  type        = bool
  description = "Whether to enable server authentication or not ?"
  default     = false
}

variable "administrator_login" {
  type        = string
  description = "The Administrator login for the PostgreSQL Flexible Server. Required when `create_mode` is `Default` and `password_auth_enabled` is `true`."
  default     = "psqladmin"
}

variable "administrator_password" {
  type        = string
  description = "The Password associated with the administrator_login for the PostgreSQL Flexible Server. Required when `create_mode` is `Default` and `password_auth_enabled` is `true`."
  default     = null
  sensitive   = true
}

variable "backup_retention_days" {
  type        = number
  description = "The backup retention days for the PostgreSQL Flexible Server. Possible values are between 7 and 35 days."
  default     = null
}

variable "create_mode" {
  type        = string
  description = "The creation mode which can be used to restore or replicate existing servers. Possible values are Default, PointInTimeRestore, Replica and Update."
  default     = null
}

variable "create_private_link_dns_zone" {
  type        = bool
  description = "Wether to create to private DNS zone for Azure Private Link"
  default     = false
}

variable "create_server" {
  type        = bool
  description = "Whether to create a new postgresql flexible server or not?"
  default     = true
}

variable "create_server_configuration" {
  type        = bool
  description = "Whether to create a new postgresql flexible server configuration or not?"
  default     = false
}

variable "databases" {
  type = list(object({
    name      = string
    charset   = optional(string, null)
    collation = optional(string, null)
  }))

  description = "A list of Azure postgressql flexible server databases with `name` as required key. Use [Charset-Table](https://www.postgresql.org/docs/13/multibyte.html#CHARSET-TABLE) charset and collation values."
  default     = []
}

variable "day_of_week" {
  type        = number
  description = "The day of week for maintenance window, where the week starts on a Sunday, i.e. Sunday = 0, Monday = 1. Defaults to 0"
  default     = 0
}

variable "delegated_subnet_id" {
  type        = string
  description = "The ID of the virtual network subnet to create the PostgreSQL Flexible Server. The provided subnet should not have any other resource deployed in it and this subnet will be delegated to the PostgreSQL Flexible Server, if not already delegated."
  default     = null
}

variable "enable_maintenance_window" {
  type        = bool
  description = "Whether maintenance window is enabled or not?"
  default     = false
}

variable "enable_server_all_category_group_log" {
  type        = bool
  description = "Whether to enable all category group log for flexible postgresql server or not?"
  default     = false
}

variable "enable_server_all_metrics" {
  type        = bool
  description = "Whether to enable all metrics for diagnostics for flexible postgresql server or not?"
  default     = false
}

variable "enable_server_audit_category_group_log" {
  type        = string
  description = "Whether or not Active Directory authentication is allowed to access the PostgreSQL Flexible Server."
  default     = false
}

variable "enable_server_custom_categories_log" {
  type        = string
  description = "Whether to enable custom categories log for flexible postgresql server or not?"
  default     = false
}

variable "enable_server_log_monitor_diagnostic" {
  type        = bool
  description = "Whether to enable the log monitor diagnostic for flexible postgresql server or not?"
  default     = true
}

variable "enable_server_log_retention_policy" {
  type        = bool
  description = "Whether to enable log retention policy for flexible postgresql server or not?"
  default     = true
}

variable "enable_server_metric_retention_policy" {
  type        = string
  description = "Whether to enable metric retention policy for flexible postgresql server or not?"
  default     = true
}

variable "eventhub_authorization_rule_id" {
  type        = string
  description = "Specifies the ID of an Event Hub Namespace Authorization Rule used to send Diagnostics Data."
  default     = null
}

variable "eventhub_name" {
  type        = string
  description = "Specifies the name of the Event Hub where Diagnostics Data should be sent."
  default     = null
}

variable "existing_server_id" {
  description = "Resource ID of existing postgresql flexible server."
  type        = string
  default     = ""
}

variable "firewall_rules" {
  description = <<-EOD
    A list of Azure SQL Firewall Rules with `name`, `start_ip_address`, and `end_ip_address` as required keys.

    **Example**:
    ```
    [
      {
        name             = "FirewallRule1"
        start_ip_address = "10.0.17.62"
        end_ip_address   = "10.0.17.62"
      },
      {
        name             = "FirewallRule2"
        start_ip_address = "172.16.30.0"
        end_ip_address   = "172.16.30.255"
      }
    ]
    ```
  EOD
  default     = []
  type = list(object({
    name             = string
    start_ip_address = string
    end_ip_address   = string
  }))
}

variable "geo_redundant_backup_enabled" {
  description = "Is Geo-Redundant backup enabled on the PostgreSQL Flexible Server. Defaults to false."
  default     = null
  type        = bool
}

variable "key_vault_id" {
  type        = string
  description = "Key Vault ID where admin credentials needs to be stored.Required if `create_server_configuration` is true."
  default     = null
}

variable "location" {
  description = "The Azure Region where the PostgreSQL Flexible Server should exist.Required if `create_server_configuration` is true."
  type        = string
  default     = null
}

variable "log_analytics_destination_type" {
  type        = string
  description = " Possible values are AzureDiagnostics and Dedicated. When set to Dedicated, logs sent to a Log Analytics workspace will go into resource specific tables, instead of the legacy AzureDiagnostics table"
  default     = null
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Specifies the ID of a Log Analytics Workspace where Diagnostics Data should be sent."
  default     = null
}

variable "maintenance_start_hour" {
  description = "The start hour for maintenance window. Defaults to 0"
  default     = 0
  type        = number
}

variable "maintenance_start_minute" {
  description = "The start minute for maintenance window. Defaults to 0"
  default     = 0
  type        = number
}

variable "monitor_diagnostic_storage_account_id" {
  type        = string
  description = "The ID of the Storage Account where logs should be sent."
  default     = null
}

variable "name" {
  description = "The name which should be used for this PostgreSQL Flexible Server. Required if `create_server` is true."
  type        = string
  default     = null
}

variable "partner_solution_id" {
  type        = string
  description = "The ID of the market partner solution where Diagnostics Data should be sent. For potential partner integrations, click to learn more about partner integration."
  default     = null
}

variable "password_auth_enabled" {
  description = "Whether or not password authentication is allowed to access the PostgreSQL Flexible Server."
  default     = true
  type        = bool
}

variable "point_in_time_restore_time_in_utc" {
  description = "The point in time to restore from source_server_id when create_mode is PointInTimeRestore."
  default     = null
  type        = string
}

variable "postgresql_version" {
  description = "The version of PostgreSQL Flexible Server to use. Possible values are 11,12, 13 and 14. Required when create_mode is Default."
  default     = null
  type        = number
}

variable "private_dns_zone_id" {
  description = "The ID of the private DNS zone to create the PostgreSQL Flexible Server."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "The name of the Resource Group where the PostgreSQL Flexible Server should exist.Required if `create_server_configuration` is true."
  type        = string
  default     = null
}

variable "server_configuration_name" {
  description = "Specifies the name of the PostgreSQL Configuration, which needs to be a valid [PostgreSQL configuration name](https://www.postgresql.org/docs/current/sql-syntax-lexical.html#SQL-SYNTAX-IDENTIFIER). Required if `create_server_configuration` is true."
  default     = null
  type        = string
}

variable "server_configuration_value" {
  description = "Specifies the value of the PostgreSQL Configuration. See the PostgreSQL documentation for valid values,Required if `create_server_configuration` is true."
  default     = null
  type        = string
}

variable "server_custom_log_categories" {
  type        = list(string)
  description = "A list of strings with supported category groups for postgresql server log monitoring diagnostics"
  default     = []
}

variable "server_log_retention_policy_days" {
  type        = string
  description = "The number of days for which this Retention Policy should apply for logs for flexible postgresql server."
  default     = 30
}

variable "server_metric_retention_policy_days" {
  type        = string
  description = "The number of days for which this Retention Policy should apply for metrics for flexible postgresql server."
  default     = 30
}

variable "sku_name" {
  description = "The SKU Name for the PostgreSQL Flexible Server. The name of the SKU, follows the tier + name pattern (e.g. B_Standard_B1ms, GP_Standard_D2s_v3, MO_Standard_E4s_v3)."
  default     = null
  type        = string
}

variable "source_server_id" {
  description = "The resource ID of the source PostgreSQL Flexible Server to be restored. Required when create_mode is PointInTimeRestore or Replica."
  default     = null
  type        = string
}

variable "storage_mb" {
  description = "The max storage allowed for the PostgreSQL Flexible Server. Possible values are 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, and 16777216."
  default     = null
  type        = number
}

variable "tags" {
  description = "A mapping of tags which should be assigned to the PostgreSQL Flexible Server.Required if `create_server_configuration` is true."
  type        = map(string)
  default     = {}
}

variable "tenant_id" {
  description = "The Tenant ID of the Azure Active Directory which is used by the Active Directory authentication. `active_directory_auth_enabled` must be set to `true`."
  default     = null
  type        = string
}

variable "zone" {
  description = "Specifies the Availability Zone in which the PostgreSQL Flexible Server should be located."
  default     = null
  type        = string
}
