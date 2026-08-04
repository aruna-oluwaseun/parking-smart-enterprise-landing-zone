output "resource_group_names" {
  value = {
    platform   = azurerm_resource_group.platform.name
    networking = azurerm_resource_group.networking.name
    monitoring = azurerm_resource_group.monitoring.name
    security   = azurerm_resource_group.security.name
    workloads  = azurerm_resource_group.workloads.name
  }
}

output "log_analytics_workspace" {
  value = {
    name         = azurerm_log_analytics_workspace.main.name
    workspace_id = azurerm_log_analytics_workspace.main.workspace_id
  }
}

output "networking" {
  value = {
    hub_vnet_name              = azurerm_virtual_network.hub.name
    application_spoke_name     = azurerm_virtual_network.application_spoke.name
    hub_management_subnet_name = azurerm_subnet.hub_management.name
    application_subnet_name    = azurerm_subnet.application.name
    aks_subnet_name            = azurerm_subnet.aks.name
  }
}

output "container_registry" {
  value = {
    name         = azurerm_container_registry.main.name
    login_server = azurerm_container_registry.main.login_server
  }
}

output "key_vault" {
  value = {
    name = azurerm_key_vault.main.name
    id   = azurerm_key_vault.main.id
  }
}

output "workload_identity" {
  value = {
    name         = azurerm_user_assigned_identity.workload.name
    client_id    = azurerm_user_assigned_identity.workload.client_id
    principal_id = azurerm_user_assigned_identity.workload.principal_id
  }
}

output "aks_cluster" {
  value = var.deploy_aks ? {
    name                = azurerm_kubernetes_cluster.main[0].name
    resource_group_name = azurerm_kubernetes_cluster.main[0].resource_group_name
    node_resource_group = azurerm_kubernetes_cluster.main[0].node_resource_group
    oidc_issuer_url     = azurerm_kubernetes_cluster.main[0].oidc_issuer_url
    kubelet_identity_id = azurerm_kubernetes_cluster.main[0].kubelet_identity[0].object_id
  } : null
}

output "policy_assignments" {
  value = {
    allowed_locations = azurerm_subscription_policy_assignment.allowed_locations.id
    required_tags     = azurerm_subscription_policy_assignment.required_tags.id
  }
}