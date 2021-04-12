resource random_string identity {
  length  = 6
  upper   = false
  lower   = true
  number  = true
  special = false
}

resource azurerm_user_assigned_identity aks_identity {
  name                 = "mi-${random_string.identity.result}"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
}
