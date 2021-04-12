resource "azurerm_kubernetes_cluster" "aks" {
  name                            = var.cluster_name
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  dns_prefix                      = var.dns_name
  kubernetes_version              = var.kubernetes_version
  api_server_authorized_ip_ranges = var.auth_ip_range

  default_node_pool {
    name                  = "system"
    vm_size               = "Standard_D2_v2"
    type                  = "VirtualMachineScaleSets"
    availability_zones    = ["1", "2", "3"]
    enable_auto_scaling   = true
    min_count             = 1
    max_count             = 3
    vnet_subnet_id        = azurerm_subnet.private_subnet.id
    enable_node_public_ip = false
    orchestrator_version = var.kubernetes_version
    os_disk_size_gb       = 1024
    max_pods              = 30
  }

  addon_profile {
    azure_policy {
      enabled = true
    }

    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
    }
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    network_policy    = "calico"
    outbound_type     = "loadBalancer"
  }

  role_based_access_control {
    azure_active_directory {
      managed                = true
      admin_group_object_ids = [azuread_group.aks_admin_group.object_id]
    }
    enabled = true
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  vm_size               = "Standard_D2_v2"
  availability_zones    = ["1", "2", "3"]
  enable_auto_scaling   = true
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  min_count             = var.min_user_np_count
  max_count             = var.min_user_np_count
  vnet_subnet_id        = azurerm_subnet.private_subnet.id
  enable_node_public_ip = false
  orchestrator_version  = var.kubernetes_version
  os_disk_size_gb       = 1024
}

resource "azurerm_role_assignment" "aks_monitoring" {
  scope = azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id = azurerm_kubernetes_cluster.aks.addon_profile[0].oms_agent[0].oms_agent_identity[0].object_id
}

resource "azurerm_role_assignment" "aks_subnet" {
  scope = azurerm_subnet.private_subnet.id
  role_definition_name = "Network Contributor"
  principal_id = azurerm_kubernetes_cluster.aks.identity.0.principal_id
}

resource "azurerm_role_assignment" "vm_contributor" {
  scope = azurerm_resource_group.rg.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
}

resource "azurerm_role_assignment" "all_mi_operator" {
  scope = data.azurerm_resource_group.aks_node_rg.id
  role_definition_name = "Managed Identity Operator"
  principal_id = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
}

resource "azurerm_role_assignment" "rg_all_mi_operator" {
  scope = azurerm_resource_group.rg.id
  role_definition_name = "Managed Identity Operator"
  principal_id = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
}

resource "azurerm_role_assignment" "mi_operator" {
  scope = azurerm_user_assigned_identity.aks_identity.id
  role_definition_name = "Managed Identity Operator"
  principal_id = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
}

resource "azurerm_role_assignment" "acr_role" {
  scope = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
}

data azurerm_resource_group aks_node_rg {
  name = azurerm_kubernetes_cluster.aks.node_resource_group
}
