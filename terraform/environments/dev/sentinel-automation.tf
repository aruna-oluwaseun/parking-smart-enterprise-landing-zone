##############################################
# Microsoft Sentinel Response-as-Code
##############################################

locals {
  password_spray_automation = yamldecode(
    file("${path.module}/../../../sentinel/automation-rules/password-spray.yaml")
  )
}

##############################################
# Password Spray Automation Rule
##############################################

resource "azurerm_sentinel_automation_rule" "password_spray" {
  count = var.deploy_sentinel ? 1 : 0

  name                       = local.password_spray_automation.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  display_name               = local.password_spray_automation.name
  order                      = local.password_spray_automation.order
  enabled                    = local.password_spray_automation.enabled

  triggers_on   = "Incidents"
  triggers_when = "Created"

  ##############################################
  # Conditions
  ##############################################

  condition_json = jsonencode([
    {
      conditionType = "Property"
      conditionProperties = {
        propertyName   = "IncidentTitle"
        operator       = "Contains"
        propertyValues = local.password_spray_automation.trigger.incidentTitleContains
      }
    },
    {
      conditionType = "Property"
      conditionProperties = {
        propertyName   = "IncidentSeverity"
        operator       = "Equals"
        propertyValues = local.password_spray_automation.incident.severity
      }
    },
    {
      conditionType = "Property"
      conditionProperties = {
        propertyName   = "IncidentStatus"
        operator       = "Equals"
        propertyValues = local.password_spray_automation.status
      }
    }
  ])

  ##############################################
  # Run Logic App Playbook
  ##############################################

  action_playbook {
    order        = 1
    logic_app_id = azurerm_logic_app_workflow.notify_security_team[0].id
  }

  depends_on = [
    azurerm_sentinel_log_analytics_workspace_onboarding.main,
    azurerm_logic_app_workflow.notify_security_team
  ]
}