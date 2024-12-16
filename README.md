<!-- markdownlint-disable first-line-h1 no-inline-html -->

> [!NOTE]
> This repository is publicly accessible as part of our open-source initiative. We welcome contributions from the community alongside our organization's primary development efforts.

---

# terraform-module-template

[![SemVer](https://img.shields.io/badge/SemVer-2.0.0-blue.svg)](https://github.com/cloudeteer/terraform-module-template/releases)

Terraform Module Template

<!-- BEGIN_TF_DOCS -->
## Usage

This example demonstrates the usage of this Terraform module with default settings.

```hcl
resource "azurerm_resource_group" "example" {
  name     = "rg-example-dev-euw-01"
  location = "westeurope"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-example-dev-euw-01"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  address_space = ["10.0.0.0/8"]
}

resource "azurerm_subnet" "example" {
  name                 = "snet-example"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name

  address_prefixes = ["10.1.0.0/16"]
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "example" {
  name                = "kv-example-dev-euw-01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  purge_protection_enabled = false
  sku_name                 = "standard"
  tenant_id                = data.azurerm_client_config.current.tenant_id

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
  }
}

resource "azurerm_storage_account" "example" {
  name                     = "stexampledeveuw01"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

module "example" {
  source = "cloudeteer/postgresql/azurerm"

  name                = "psql-example-dev-euw-01"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  key_vault_id                          = azurerm_key_vault.example.id
  delegated_subnet_id                   = azurerm_subnet.example.id
  monitor_diagnostic_storage_account_id = azurerm_storage_account.example.id
  create_private_link_dns_zone          = true

  postgresql_version = "16"
  sku_name           = "GP_Standard_D2s_v3"
  zone               = "1"

  databases = [
    {
      name      = "db-example-01"
      collation = "en_US.utf8"
      charset   = "UTF8"
    },
    {
      name      = "db-example-02"
      collation = "en_US.utf8"
      charset   = "UTF8"
  }]

  enable_server_all_metrics              = true
  enable_server_audit_category_group_log = true
}
```

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (>= 3.1)

- <a name="provider_random"></a> [random](#provider\_random) (>= 3.1)

- <a name="provider_time"></a> [time](#provider\_time) (>= 0.12)



## Resources

The following resources are used by this module:

- [azurerm_key_vault_secret.administrator_login](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) (resource)
- [azurerm_key_vault_secret.administrator_login_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) (resource)
- [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) (resource)
- [azurerm_postgresql_flexible_server.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server) (resource)
- [azurerm_postgresql_flexible_server_active_directory_administrator.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_active_directory_administrator) (resource)
- [azurerm_postgresql_flexible_server_configuration.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_configuration) (resource)
- [azurerm_postgresql_flexible_server_database.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_database) (resource)
- [azurerm_postgresql_flexible_server_firewall_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_firewall_rule) (resource)
- [azurerm_private_dns_zone.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) (resource)
- [azurerm_private_dns_zone_virtual_network_link.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) (resource)
- [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) (resource)
- [time_sleep.wait_60_seconds_after_server_creation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) (resource)
- [azurerm_monitor_diagnostic_categories.server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_diagnostic_categories) (data source)


## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_active_directory_administrators"></a> [active\_directory\_administrators](#input\_active\_directory\_administrators)

Description: A list of Active Directory objects (user, service principal or security group) designated as administrators for the PostgreSQL server.

See [azurerm\_postgresql\_flexible\_server\_active\_directory\_administrator](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_active_directory_administrator) for a details.
- `object_id` - (Required) The object ID of a user, service principal or security group in the Azure Active Directory tenant set as the Server Admin.
- `principal_name` - (Required) The name of Azure Active Directory principal. Changing this forces a new resource to be created.
- `principal_type` - (Required) The type of Azure Active Directory principal. Possible values are `Group`, `ServicePrincipal` and `User`.

**NOTE**: This list is only considered when `active_directory_auth_enabled` is set to `true`.

Type:

```hcl
list(object({
    object_id      = string
    principal_name = string
    principal_type = string
  }))
```

Default: `[]`

### <a name="input_active_directory_auth_enabled"></a> [active\_directory\_auth\_enabled](#input\_active\_directory\_auth\_enabled)

Description: Whether to enable server authentication or not ?

Type: `bool`

Default: `false`

### <a name="input_administrator_login"></a> [administrator\_login](#input\_administrator\_login)

Description: The Administrator login for the PostgreSQL Flexible Server. Required when `create_mode` is `Default` and `password_auth_enabled` is `true`.

Type: `string`

Default: `"psqladmin"`

### <a name="input_administrator_password"></a> [administrator\_password](#input\_administrator\_password)

Description: The Password associated with the administrator\_login for the PostgreSQL Flexible Server. Required when `create_mode` is `Default` and `password_auth_enabled` is `true`.

Type: `string`

Default: `null`

### <a name="input_backup_retention_days"></a> [backup\_retention\_days](#input\_backup\_retention\_days)

Description: The backup retention days for the PostgreSQL Flexible Server. Possible values are between 7 and 35 days.

Type: `number`

Default: `null`

### <a name="input_create_mode"></a> [create\_mode](#input\_create\_mode)

Description: The creation mode which can be used to restore or replicate existing servers. Possible values are Default, PointInTimeRestore, Replica and Update.

Type: `string`

Default: `null`

### <a name="input_create_private_link_dns_zone"></a> [create\_private\_link\_dns\_zone](#input\_create\_private\_link\_dns\_zone)

Description: Wether to create to private DNS zone for Azure Private Link

Type: `bool`

Default: `false`

### <a name="input_create_server"></a> [create\_server](#input\_create\_server)

Description: Whether to create a new postgresql flexible server or not?

Type: `bool`

Default: `true`

### <a name="input_create_server_configuration"></a> [create\_server\_configuration](#input\_create\_server\_configuration)

Description: Whether to create a new postgresql flexible server configuration or not?

Type: `bool`

Default: `false`

### <a name="input_databases"></a> [databases](#input\_databases)

Description: A list of Azure postgressql flexible server databases with `name` as required key. Use [Charset-Table](https://www.postgresql.org/docs/13/multibyte.html#CHARSET-TABLE) charset and collation values.

Type:

```hcl
list(object({
    name      = string
    charset   = optional(string, null)
    collation = optional(string, null)
  }))
```

Default: `[]`

### <a name="input_day_of_week"></a> [day\_of\_week](#input\_day\_of\_week)

Description: The day of week for maintenance window, where the week starts on a Sunday, i.e. Sunday = 0, Monday = 1. Defaults to 0

Type: `number`

Default: `0`

### <a name="input_delegated_subnet_id"></a> [delegated\_subnet\_id](#input\_delegated\_subnet\_id)

Description: The ID of the virtual network subnet to create the PostgreSQL Flexible Server. The provided subnet should not have any other resource deployed in it and this subnet will be delegated to the PostgreSQL Flexible Server, if not already delegated.

Type: `string`

Default: `null`

### <a name="input_enable_maintenance_window"></a> [enable\_maintenance\_window](#input\_enable\_maintenance\_window)

Description: Whether maintenance window is enabled or not?

Type: `bool`

Default: `false`

### <a name="input_enable_server_all_category_group_log"></a> [enable\_server\_all\_category\_group\_log](#input\_enable\_server\_all\_category\_group\_log)

Description: Whether to enable all category group log for flexible postgresql server or not?

Type: `bool`

Default: `false`

### <a name="input_enable_server_all_metrics"></a> [enable\_server\_all\_metrics](#input\_enable\_server\_all\_metrics)

Description: Whether to enable all metrics for diagnostics for flexible postgresql server or not?

Type: `bool`

Default: `false`

### <a name="input_enable_server_audit_category_group_log"></a> [enable\_server\_audit\_category\_group\_log](#input\_enable\_server\_audit\_category\_group\_log)

Description: Whether or not Active Directory authentication is allowed to access the PostgreSQL Flexible Server.

Type: `string`

Default: `false`

### <a name="input_enable_server_custom_categories_log"></a> [enable\_server\_custom\_categories\_log](#input\_enable\_server\_custom\_categories\_log)

Description: Whether to enable custom categories log for flexible postgresql server or not?

Type: `string`

Default: `false`

### <a name="input_enable_server_log_monitor_diagnostic"></a> [enable\_server\_log\_monitor\_diagnostic](#input\_enable\_server\_log\_monitor\_diagnostic)

Description: Whether to enable the log monitor diagnostic for flexible postgresql server or not?

Type: `bool`

Default: `true`

### <a name="input_enable_server_log_retention_policy"></a> [enable\_server\_log\_retention\_policy](#input\_enable\_server\_log\_retention\_policy)

Description: Whether to enable log retention policy for flexible postgresql server or not?

Type: `bool`

Default: `true`

### <a name="input_enable_server_metric_retention_policy"></a> [enable\_server\_metric\_retention\_policy](#input\_enable\_server\_metric\_retention\_policy)

Description: Whether to enable metric retention policy for flexible postgresql server or not?

Type: `string`

Default: `true`

### <a name="input_eventhub_authorization_rule_id"></a> [eventhub\_authorization\_rule\_id](#input\_eventhub\_authorization\_rule\_id)

Description: Specifies the ID of an Event Hub Namespace Authorization Rule used to send Diagnostics Data.

Type: `string`

Default: `null`

### <a name="input_eventhub_name"></a> [eventhub\_name](#input\_eventhub\_name)

Description: Specifies the name of the Event Hub where Diagnostics Data should be sent.

Type: `string`

Default: `null`

### <a name="input_existing_server_id"></a> [existing\_server\_id](#input\_existing\_server\_id)

Description: Resource ID of existing postgresql flexible server.

Type: `string`

Default: `""`

### <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules)

Description: A list of Azure SQL Firewall Rules with `name`, `start_ip_address`, and `end_ip_address` as required keys.

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

Type:

```hcl
list(object({
    name             = string
    start_ip_address = string
    end_ip_address   = string
  }))
```

Default: `[]`

### <a name="input_geo_redundant_backup_enabled"></a> [geo\_redundant\_backup\_enabled](#input\_geo\_redundant\_backup\_enabled)

Description: Is Geo-Redundant backup enabled on the PostgreSQL Flexible Server. Defaults to false.

Type: `bool`

Default: `null`

### <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id)

Description: Key Vault ID where admin credentials needs to be stored.Required if `create_server_configuration` is true.

Type: `string`

Default: `null`

### <a name="input_location"></a> [location](#input\_location)

Description: The Azure Region where the PostgreSQL Flexible Server should exist.Required if `create_server_configuration` is true.

Type: `string`

Default: `null`

### <a name="input_log_analytics_destination_type"></a> [log\_analytics\_destination\_type](#input\_log\_analytics\_destination\_type)

Description:  Possible values are AzureDiagnostics and Dedicated. When set to Dedicated, logs sent to a Log Analytics workspace will go into resource specific tables, instead of the legacy AzureDiagnostics table

Type: `string`

Default: `null`

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: Specifies the ID of a Log Analytics Workspace where Diagnostics Data should be sent.

Type: `string`

Default: `null`

### <a name="input_maintenance_start_hour"></a> [maintenance\_start\_hour](#input\_maintenance\_start\_hour)

Description: The start hour for maintenance window. Defaults to 0

Type: `number`

Default: `0`

### <a name="input_maintenance_start_minute"></a> [maintenance\_start\_minute](#input\_maintenance\_start\_minute)

Description: The start minute for maintenance window. Defaults to 0

Type: `number`

Default: `0`

### <a name="input_monitor_diagnostic_storage_account_id"></a> [monitor\_diagnostic\_storage\_account\_id](#input\_monitor\_diagnostic\_storage\_account\_id)

Description: The ID of the Storage Account where logs should be sent.

Type: `string`

Default: `null`

### <a name="input_name"></a> [name](#input\_name)

Description: The name which should be used for this PostgreSQL Flexible Server. Required if `create_server` is true.

Type: `string`

Default: `null`

### <a name="input_partner_solution_id"></a> [partner\_solution\_id](#input\_partner\_solution\_id)

Description: The ID of the market partner solution where Diagnostics Data should be sent. For potential partner integrations, click to learn more about partner integration.

Type: `string`

Default: `null`

### <a name="input_password_auth_enabled"></a> [password\_auth\_enabled](#input\_password\_auth\_enabled)

Description: Whether or not password authentication is allowed to access the PostgreSQL Flexible Server.

Type: `bool`

Default: `true`

### <a name="input_point_in_time_restore_time_in_utc"></a> [point\_in\_time\_restore\_time\_in\_utc](#input\_point\_in\_time\_restore\_time\_in\_utc)

Description: The point in time to restore from source\_server\_id when create\_mode is PointInTimeRestore.

Type: `string`

Default: `null`

### <a name="input_postgresql_version"></a> [postgresql\_version](#input\_postgresql\_version)

Description: The version of PostgreSQL Flexible Server to use. Possible values are 11,12, 13 and 14. Required when create\_mode is Default.

Type: `number`

Default: `null`

### <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id)

Description: The ID of the private DNS zone to create the PostgreSQL Flexible Server.

Type: `string`

Default: `null`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the Resource Group where the PostgreSQL Flexible Server should exist.Required if `create_server_configuration` is true.

Type: `string`

Default: `null`

### <a name="input_server_configuration_name"></a> [server\_configuration\_name](#input\_server\_configuration\_name)

Description: Specifies the name of the PostgreSQL Configuration, which needs to be a valid [PostgreSQL configuration name](https://www.postgresql.org/docs/current/sql-syntax-lexical.html#SQL-SYNTAX-IDENTIFIER). Required if `create_server_configuration` is true.

Type: `string`

Default: `null`

### <a name="input_server_configuration_value"></a> [server\_configuration\_value](#input\_server\_configuration\_value)

Description: Specifies the value of the PostgreSQL Configuration. See the PostgreSQL documentation for valid values,Required if `create_server_configuration` is true.

Type: `string`

Default: `null`

### <a name="input_server_custom_log_categories"></a> [server\_custom\_log\_categories](#input\_server\_custom\_log\_categories)

Description: A list of strings with supported category groups for postgresql server log monitoring diagnostics

Type: `list(string)`

Default: `[]`

### <a name="input_server_log_retention_policy_days"></a> [server\_log\_retention\_policy\_days](#input\_server\_log\_retention\_policy\_days)

Description: The number of days for which this Retention Policy should apply for logs for flexible postgresql server.

Type: `string`

Default: `30`

### <a name="input_server_metric_retention_policy_days"></a> [server\_metric\_retention\_policy\_days](#input\_server\_metric\_retention\_policy\_days)

Description: The number of days for which this Retention Policy should apply for metrics for flexible postgresql server.

Type: `string`

Default: `30`

### <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name)

Description: The SKU Name for the PostgreSQL Flexible Server. The name of the SKU, follows the tier + name pattern (e.g. B\_Standard\_B1ms, GP\_Standard\_D2s\_v3, MO\_Standard\_E4s\_v3).

Type: `string`

Default: `null`

### <a name="input_source_server_id"></a> [source\_server\_id](#input\_source\_server\_id)

Description: The resource ID of the source PostgreSQL Flexible Server to be restored. Required when create\_mode is PointInTimeRestore or Replica.

Type: `string`

Default: `null`

### <a name="input_storage_mb"></a> [storage\_mb](#input\_storage\_mb)

Description: The max storage allowed for the PostgreSQL Flexible Server. Possible values are 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, and 16777216.

Type: `number`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A mapping of tags which should be assigned to the PostgreSQL Flexible Server.Required if `create_server_configuration` is true.

Type: `map(string)`

Default: `{}`

### <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id)

Description: The Tenant ID of the Azure Active Directory which is used by the Active Directory authentication. `active_directory_auth_enabled` must be set to `true`.

Type: `string`

Default: `null`

### <a name="input_zone"></a> [zone](#input\_zone)

Description: Specifies the Availability Zone in which the PostgreSQL Flexible Server should be located.

Type: `string`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_administrator_login"></a> [administrator\_login](#output\_administrator\_login)

Description: The Administrator login for the PostgreSQL Flexible Server.

### <a name="output_administrator_password"></a> [administrator\_password](#output\_administrator\_password)

Description: The Password associated with the `administrator_login` for the PostgreSQL Flexible Server.

### <a name="output_database_id"></a> [database\_id](#output\_database\_id)

Description: The ID of the Azure PostgreSQL Flexible Server Database.

### <a name="output_fqdn"></a> [fqdn](#output\_fqdn)

Description: The FQDN of the PostgreSQL Flexible Server.

### <a name="output_server_id"></a> [server\_id](#output\_server\_id)

Description: The ID of the PostgreSQL Flexible Server.
<!-- END_TF_DOCS -->

## Contributions

We welcome all kinds of contributions, whether it's reporting bugs, submitting feature requests, or directly contributing to the development. Please read our [Contributing Guidelines](CONTRIBUTING.md) to learn how you can best contribute.

Thank you for your interest and support!

## Copyright and license

<img width=200 alt="Logo" src="https://raw.githubusercontent.com/cloudeteer/cdt-public/main/img/cdt_logo_orig_4c.svg">

© 2024 CLOUDETEER GmbH

This project is licensed under the [MIT License](LICENSE).
