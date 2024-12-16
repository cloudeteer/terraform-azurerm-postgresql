output "administrator_login" {
  value       = try(azurerm_postgresql_flexible_server.this[0].administrator_login, null)
  description = "The Administrator login for the PostgreSQL Flexible Server."
}

output "administrator_password" {
  description = "The Password associated with the `administrator_login` for the PostgreSQL Flexible Server."
  value       = try(azurerm_postgresql_flexible_server.this[0].administrator_password, null)
}

output "database_id" {
  description = "The ID of the Azure PostgreSQL Flexible Server Database."
  value = {
    for k, v in azurerm_postgresql_flexible_server_database.this : k => v.id
  }
}

output "fqdn" {
  description = "The FQDN of the PostgreSQL Flexible Server."
  value       = try(azurerm_postgresql_flexible_server.this[0].fqdn, null)
}

output "server_id" {
  description = "The ID of the PostgreSQL Flexible Server."
  value       = try(azurerm_postgresql_flexible_server.this[0].id, null)
}
