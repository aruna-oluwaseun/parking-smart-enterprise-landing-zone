##############################################
# Azure Container Registry (ACR)
##############################################

resource "azurerm_container_registry" "main" {
  # checkov:skip=CKV_AZURE_164:Docker Content Trust is deprecated in ACR; image signing and verification will use Notary Project/Notation or Cosign.

  name                = "acr${var.project_name}${var.environment}001"
  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location

  sku                           = "Premium"
  admin_enabled                 = false
  public_network_access_enabled = false

  tags = local.common_tags
}

##############################################
# ACR Private DNS
##############################################

resource "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.networking.name

  tags = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr" {
  name                  = "link-${local.name_prefix}-acr"
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.acr.name
  virtual_network_id    = azurerm_virtual_network.application_spoke.id

  registration_enabled = false

  tags = local.common_tags
}

##############################################
# ACR Private Endpoint
##############################################

resource "azurerm_private_endpoint" "acr" {
  name                = "pe-${local.name_prefix}-acr"
  location            = azurerm_resource_group.networking.location
  resource_group_name = azurerm_resource_group.networking.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "psc-${local.name_prefix}-acr"
    private_connection_resource_id = azurerm_container_registry.main.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "acr-private-dns"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.acr.id
    ]
  }

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
  public_network_access_enabled = false

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }


  tags = local.common_tags
}

##############################################
# Key Vault Private DNS
##############################################

resource "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.networking.name

  tags = local.common_tags
}

##############################################
# Key Vault Private Endpoint
##############################################

resource "azurerm_private_endpoint" "key_vault" {
  name                = "pe-${local.name_prefix}-keyvault"
  location            = azurerm_resource_group.networking.location
  resource_group_name = azurerm_resource_group.networking.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "psc-${local.name_prefix}-keyvault"
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "keyvault-private-dns"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.key_vault.id
    ]
  }

  tags = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  name                  = "link-${local.name_prefix}-keyvault"
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = azurerm_virtual_network.application_spoke.id

  registration_enabled = false

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