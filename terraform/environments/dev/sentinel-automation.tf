##############################################
# Microsoft Sentinel Response-as-Code
##############################################

locals {
  sentinel_automation_rule_path = "${path.module}/../../../sentinel/automation-rules"

  sentinel_automation_rule_files = fileset(
    local.sentinel_automation_rule_path,
    "*.yaml"
  )

  sentinel_automation_rules = {
    for filename in local.sentinel_automation_rule_files :
    trimsuffix(filename, ".yaml") => yamldecode(
      file("${local.sentinel_automation_rule_path}/${filename}")
    )
  }

  ##############################################
  # Playbook → Logic App Mapping
  ##############################################

  playbook_logic_app_ids = {
    "notify-teams"    = one(azurerm_logic_app_workflow.notify_security_team[*].id)
    "enrich-ioc"      = one(azurerm_logic_app_workflow.enrich_ioc[*].id)
    "disable-account" = one(azurerm_logic_app_workflow.disable_account[*].id)
    "create-incident" = one(azurerm_logic_app_workflow.create_incident[*].id)
  }

  ##############################################
  # Deploy automation rules only when
  # Sentinel deployment is enabled
  ##############################################

  enabled_sentinel_automation_rules = {
    for key, rule in local.sentinel_automation_rules :
    key => rule
    if var.deploy_sentinel
  }
}

##############################################
# Microsoft Sentinel Automation Rules
##############################################

resource "azurerm_sentinel_automation_rule" "responses" {
  for_each = local.enabled_sentinel_automation_rules

  name                       = each.value.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  display_name = each.value.name
  order        = each.value.order
  enabled      = each.value.enabled

  triggers_on   = "Incidents"
  triggers_when = "Created"

  ##############################################
  # Incident Conditions
  ##############################################

  condition_json = jsonencode([
    {
      conditionType = "Property"

      conditionProperties = {
        propertyName   = "IncidentTitle"
        operator       = "Contains"
        propertyValues = each.value.trigger.incidentTitleContains
      }
    },
    {
      conditionType = "Property"

      conditionProperties = {
        propertyName   = "IncidentSeverity"
        operator       = "Equals"
        propertyValues = each.value.incident.severity
      }
    },
    {
      conditionType = "Property"

      conditionProperties = {
        propertyName   = "IncidentStatus"
        operator       = "Equals"
        propertyValues = each.value.status
      }
    }
  ])

  ##############################################
  # Execute Playbooks Defined in YAML
  ##############################################

  dynamic "action_playbook" {
    for_each = try(each.value.actions, [])

    content {
      order = action_playbook.key + 1

      logic_app_id = local.playbook_logic_app_ids[
        action_playbook.value.playbook
      ]
    }
  }

  ##############################################
  # Dependencies
  ##############################################

  depends_on = [
    azurerm_sentinel_log_analytics_workspace_onboarding.main,
    azurerm_logic_app_workflow.notify_security_team,
    azurerm_logic_app_workflow.enrich_ioc,
    azurerm_logic_app_workflow.disable_account,

  ]
}