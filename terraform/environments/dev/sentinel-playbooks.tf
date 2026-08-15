##############################################
# Microsoft Sentinel SOAR
#
# Deploys Logic Apps used as
# Microsoft Sentinel Playbooks.
##############################################

##############################################
# Microsoft Sentinel SOAR Playbooks
##############################################

##############################################
# Notify Security Team Logic App
##############################################

resource "azurerm_logic_app_workflow" "notify_security_team" {
  count = var.deploy_sentinel ? 1 : 0

  name                = "logic-${local.name_prefix}-notify-security"
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name

  enabled = true

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

##############################################
# Request Trigger
##############################################

resource "azurerm_logic_app_trigger_http_request" "notify_security_team" {
  count = var.deploy_sentinel ? 1 : 0

  name         = "When_Sentinel_Incident_Is_Received"
  logic_app_id = azurerm_logic_app_workflow.notify_security_team[0].id

  schema = jsonencode({
    type = "object"

    properties = {
      incidentTitle = {
        type = "string"
      }

      incidentSeverity = {
        type = "string"
      }

      incidentUrl = {
        type = "string"
      }

      description = {
        type = "string"
      }
    }
  })
}

##############################################
# Build SOC Notification Payload
##############################################

resource "azurerm_logic_app_action_custom" "build_security_notification" {
  count = var.deploy_sentinel ? 1 : 0

  name         = "Build_Security_Notification"
  logic_app_id = azurerm_logic_app_workflow.notify_security_team[0].id

  body = jsonencode({
    type = "Compose"

    inputs = {
      title       = "@triggerBody()?['incidentTitle']"
      severity    = "@triggerBody()?['incidentSeverity']"
      description = "@triggerBody()?['description']"
      incidentUrl = "@triggerBody()?['incidentUrl']"

      message = "Parking Smart security incident requires investigation."
    }

    runAfter = {}
  })
}