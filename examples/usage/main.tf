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
