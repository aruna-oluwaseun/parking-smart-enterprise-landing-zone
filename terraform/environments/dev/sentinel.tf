##############################################
# Microsoft Sentinel onboarding
##############################################

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "main" {
  count = var.deploy_sentinel ? 1 : 0

  workspace_id                 = azurerm_log_analytics_workspace.main.id
  customer_managed_key_enabled = false
}