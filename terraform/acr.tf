resource "azurerm_container_registry" "acr" {
  name                     = var.acr_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  # sku                      = "Basic"
  sku                      = "Premium" # Required to enable allowed ip range set
  admin_enabled            = true

  network_rule_set {
    default_action = "Deny"
    virtual_network = [{
      action = "Allow"
      subnet_id = azurerm_subnet.private_subnet.id
    }]
    ip_rule = local.allowed_ip_range
  }
  depends_on               = [azurerm_subnet.private_subnet] 
}

locals {
  allowed_ip_range = [for ip in var.acr_ip_range : {
    action = "Allow",
    ip_range = ip
  }]
}
