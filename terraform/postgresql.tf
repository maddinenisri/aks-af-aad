resource "azurerm_postgresql_server" "postgresql_server" {
  name                         = var.postgres_service_name
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  sku_name                     = var.postgresql_sku_name
  storage_mb                   = var.postgresql_storage
  auto_grow_enabled            = true
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  # Move this to azure vault
  administrator_login              = var.postgresql_admin_login
  administrator_login_password     = random_password.postgresql_admin_password.result
  version                          = var.postgresql_version
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}

resource "random_password" "postgresql_admin_password" {
  length           = 16
  special          = true
  override_special = "_%"
}

resource "azurerm_postgresql_database" "postgresql_server_database" {
  name                = var.postgresql_db_name
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.postgresql_server.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "random_string" "private_link" {
  length  = 4
  special = false
  upper   = false
  number  = false
}

resource "azurerm_private_endpoint" "db" {
  name                = "${random_string.private_link.result}-endpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.private_subnet.id

  private_service_connection {
    name                           = "${random_string.private_link.result}-privateconnection"
    private_connection_resource_id = azurerm_postgresql_server.postgresql_server.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }
}

resource "azurerm_postgresql_virtual_network_rule" "vnet_rule" {
  name                                 = "${azurerm_postgresql_server.postgresql_server.name}-vnet-rule"
  resource_group_name                  = azurerm_resource_group.rg.name
  server_name                          = azurerm_postgresql_server.postgresql_server.name
  subnet_id                            = azurerm_subnet.private_subnet.id
  ignore_missing_vnet_service_endpoint = true
}
