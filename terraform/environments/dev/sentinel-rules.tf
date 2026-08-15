##############################################
# Sentinel Detection-as-Code
# Proof of concept: Failed Sign-ins
##############################################

locals {
  failed_signins_metadata = yamldecode(
    file("${path.module}/../../../sentinel/analytics-rules/failed-signins.yaml")
  )
}

resource "azurerm_sentinel_alert_rule_scheduled" "failed_signins" {
  count = var.deploy_sentinel ? 1 : 0

  name                       = local.failed_signins_metadata.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  display_name = local.failed_signins_metadata.name
  description  = local.failed_signins_metadata.description
  severity     = local.failed_signins_metadata.severity

  query = file(
    "${path.module}/../../../detections/sentinel/failed_signins.kql"
  )

  query_frequency = "PT5M"
  query_period    = "PT10M"

  trigger_operator  = "GreaterThan"
  trigger_threshold = 0

  tactics = local.failed_signins_metadata.tactics

  incident {
     create_incident_enabled = true

  grouping {
    enabled                 = true
    reopen_closed_incidents = false
    lookback_duration       = "PT1H"
    entity_matching_method  = "AnyAlert"
  }
  }
}