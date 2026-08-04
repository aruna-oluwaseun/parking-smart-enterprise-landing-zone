resource "azurerm_user_assigned_identity" "aks_control_plane" {
  name                = "id-${local.name_prefix}-aks-control-plane"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name

  tags = local.common_tags
}

resource "azurerm_role_assignment" "aks_subnet_network_contributor" {
  scope                = azurerm_subnet.aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_control_plane.principal_id
}

##############################################
# Azure Kubernetes Service
##############################################

resource "azurerm_kubernetes_cluster" "main" {
  count = var.deploy_aks ? 1 : 0  
  name                = "aks-${local.name_prefix}"
  location            = azurerm_resource_group.workloads.location
  resource_group_name = azurerm_resource_group.workloads.name
  dns_prefix          = "aks-${local.name_prefix}"

  node_resource_group = "rg-${local.name_prefix}-aks-nodes"

  role_based_access_control_enabled = true
  local_account_disabled            = false

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  default_node_pool {
    name           = "system"
    vm_size        = var.aks_node_vm_size
    node_count     = var.aks_system_node_count
    vnet_subnet_id = azurerm_subnet.aks.id

    only_critical_addons_enabled = true

    upgrade_settings {
      max_surge = "10%"
    }

    node_labels = {
      environment = var.environment
      workload    = "system"
    }

    tags = local.common_tags
  }

  identity {
    type = "UserAssigned"

    identity_ids = [
      azurerm_user_assigned_identity.aks_control_plane.id
    ]
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "azure"
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"

    service_cidr   = var.aks_service_cidr
    dns_service_ip = var.aks_dns_service_ip
    pod_cidr       = var.aks_pod_cidr
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  tags = local.common_tags

  depends_on = [
    azurerm_role_assignment.aks_subnet_network_contributor
  ]
}

##############################################
# Allow AKS nodes to pull images from ACR
##############################################

resource "azurerm_role_assignment" "aks_acr_pull" {
  count = var.deploy_aks ? 1 : 0  
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id = azurerm_kubernetes_cluster.main[0].kubelet_identity[0].object_id
}