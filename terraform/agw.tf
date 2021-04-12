locals {
  backend_address_pool_name      = "${azurerm_virtual_network.vnet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.vnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.vnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.vnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.vnet.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.vnet.name}-rdrcfg"
  ssl_certificate_name           = "agw_cert"
}

resource "azurerm_application_gateway" "agw" {
  name                = var.agw_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name = "WAF_V2"
    tier = "WAF_V2"
  }

  autoscale_configuration {
    min_capacity = 1
    max_capacity = 2
  }

  waf_configuration {
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.1"
    enabled          = true
  }

  zones = [1, 2, 3]

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.public_subnet.id
  }

  ssl_certificate {
    name     = local.ssl_certificate_name
    data     = filebase64(var.cert_file)
    password = var.cert_password
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_port {
    name = "${local.frontend_port_name}-443"
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.ip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  backend_http_settings {
    name                  = "${local.http_setting_name}-443"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  http_listener {
    name                           = "${local.listener_name}-https"
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = "${local.frontend_port_name}-443"
    protocol                       = "Https"
    ssl_certificate_name           = local.ssl_certificate_name
  }

  redirect_configuration {
    name                 = local.redirect_configuration_name
    redirect_type        = "Permanent"
    include_path         = true
    include_query_string = true
    target_listener_name = "${local.listener_name}-https"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  request_routing_rule {
    name                       = "${local.request_routing_rule_name}-https"
    rule_type                  = "Basic"
    http_listener_name         = "${local.listener_name}-https"
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_identity.id]
  }

  lifecycle {
    ignore_changes = [
      tags,
      backend_address_pool,
      backend_http_settings,
      frontend_port,
      http_listener,
      probe,
      request_routing_rule,
      url_path_map,
      ssl_certificate,
      redirect_configuration,
      autoscale_configuration
    ]
  }

  depends_on = [
    azurerm_user_assigned_identity.aks_identity
  ]
}

resource "azurerm_role_assignment" "role_agw" {
  scope = azurerm_application_gateway.agw.id
  role_definition_name = "Contributor"
  principal_id = azurerm_user_assigned_identity.aks_identity.principal_id
}

resource "azurerm_role_assignment" "rg_mi_role" {
  scope = azurerm_resource_group.rg.id
  role_definition_name = "Reader"
  principal_id = azurerm_user_assigned_identity.aks_identity.principal_id
}

resource "azurerm_role_assignment" "rg_all_mi_role" {
  scope = azurerm_resource_group.rg.id
  role_definition_name = "Managed Identity Operator"
  principal_id = azurerm_user_assigned_identity.aks_identity.principal_id
}

resource "null_resource" "enable_aks_addon_agw" {
  provisioner "local-exec" {
    command = "az aks enable-addons -n ${azurerm_kubernetes_cluster.aks.name} -g ${azurerm_resource_group.rg.name} -a ingress-appgw --appgw-id ${azurerm_application_gateway.agw.id}"
  }

  depends_on = [
    azurerm_kubernetes_cluster.aks,
    azurerm_application_gateway.agw,
    azurerm_role_assignment.role_agw
  ]
}