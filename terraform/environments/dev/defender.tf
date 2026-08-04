##############################################
# Microsoft Defender for Cloud
# Cost-safe foundational configuration
##############################################

resource "azurerm_security_center_subscription_pricing" "virtual_machines" {
  tier          = "Free"
  resource_type = "VirtualMachines"
}

resource "azurerm_security_center_subscription_pricing" "storage_accounts" {
  tier          = "Free"
  resource_type = "StorageAccounts"
}

resource "azurerm_security_center_subscription_pricing" "key_vaults" {
  tier          = "Free"
  resource_type = "KeyVaults"
}

resource "azurerm_security_center_subscription_pricing" "container_registry" {
  tier          = "Free"
  resource_type = "ContainerRegistry"
}

resource "azurerm_security_center_subscription_pricing" "containers" {
  tier          = "Free"
  resource_type = "Containers"
}

resource "azurerm_security_center_subscription_pricing" "app_services" {
  tier          = "Free"
  resource_type = "AppServices"
}

resource "azurerm_security_center_subscription_pricing" "open_source_databases" {
  tier          = "Free"
  resource_type = "OpenSourceRelationalDatabases"
}

resource "azurerm_security_center_subscription_pricing" "cloud_posture" {
  tier          = "Free"
  resource_type = "CloudPosture"
}