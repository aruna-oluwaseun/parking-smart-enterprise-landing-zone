##############################################
# Azure Container Registry (ACR)
##############################################

resource "azurerm_container_registry" "main" {
  name                = "acr${var.project_name}${var.environment}001"
  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location

  sku           = "Standard"
  admin_enabled = false

  tags = local.common_tags
}

##############################################
# Current Azure client configuration
##############################################

data "azurerm_client_config" "current" {}

##############################################
# Azure Key Vault
##############################################

resource "azurerm_key_vault" "main" {
  name                = "kv-${var.project_name}-${var.environment}-001"
  location            = azurerm_resource_group.security.location
  resource_group_name = azurerm_resource_group.security.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  rbac_authorization_enabled    = true
  purge_protection_enabled      = true
  soft_delete_retention_days    = 7
  public_network_access_enabled = true

  tags = local.common_tags
}

##############################################
# Workload identity
##############################################

resource "azurerm_user_assigned_identity" "workload" {
  name                = "id-${local.name_prefix}-workload"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name

  tags = local.common_tags
}

##############################################
# RBAC assignment
##############################################

resource "azurerm_role_assignment" "workload_key_vault_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.workload.principal_id
}