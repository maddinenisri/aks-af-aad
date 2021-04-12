resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "logs-${random_pet.workspace.id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = 30
}

resource "random_pet" "workspace" {

}
