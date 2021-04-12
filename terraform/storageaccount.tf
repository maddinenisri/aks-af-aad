resource "azurerm_storage_account" "sa" {
  name                     = random_pet.sa.id
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                  = "airflow-logs"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "azurerm_storage_share" "dags_share" {
  name                 = "airflow-dags"
  storage_account_name = azurerm_storage_account.sa.name
  quota                = 50
}

resource "azurerm_storage_share" "logs_share" {
  name                 = "airflow-temp"
  storage_account_name = azurerm_storage_account.sa.name
  quota                = 50
}


resource "random_pet" "sa" {

}