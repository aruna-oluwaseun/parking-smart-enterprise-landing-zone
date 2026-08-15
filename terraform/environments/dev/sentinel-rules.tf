##############################################
# Microsoft Sentinel Detection-as-Code
##############################################

locals {
  # Location of Sentinel analytics-rule metadata.
  sentinel_rule_metadata_path = "${path.module}/../../../sentinel/analytics-rules"

  # Location of KQL detection logic.
  sentinel_kql_path = "${path.module}/../../../detections/sentinel"

  ############################################
  # Discover all Sentinel analytics-rule YAML files
  ############################################

  sentinel_rule_files = fileset(
    local.sentinel_rule_metadata_path,
    "*.yaml"
  )

  ############################################
  # Decode YAML metadata into Terraform objects
  ############################################

  sentinel_rules = {
    for filename in local.sentinel_rule_files :

    trimsuffix(filename, ".yaml") => yamldecode(
      file("${local.sentinel_rule_metadata_path}/${filename}")
    )
  }

  ############################################
  # Enable deployment only when Sentinel is enabled
  ############################################

  enabled_sentinel_rules = {
    for key, rule in local.sentinel_rules :

    key => rule
    if var.deploy_sentinel
  }
}

##############################################
# Microsoft Sentinel Scheduled Analytics Rules
##############################################

resource "azurerm_sentinel_alert_rule_scheduled" "detections" {

  ############################################
  # One Sentinel rule per YAML file
  ############################################

  for_each = local.enabled_sentinel_rules

  ############################################
  # Basic rule metadata
  ############################################

  name                       = each.value.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  display_name = each.value.name
  description  = each.value.description
  severity     = each.value.severity
  enabled      = each.value.enabled

  ############################################
  # Detection logic
  #
  # The YAML tells Terraform which KQL file
  # belongs to this analytics rule.
  ############################################

  query = file(
    "${local.sentinel_kql_path}/${each.value.kqlFile}"
  )

  ############################################
  # Scheduling
  #
  # Sentinel expects ISO 8601 durations.
  #
  # Our YAML uses values such as:
  #   5m
  #   10m
  #   1h
  #
  # Convert them to:
  #   PT5M
  #   PT10M
  #   PT1H
  ############################################

  query_frequency = (
    endswith(each.value.queryFrequency, "m")
    ? "PT${upper(each.value.queryFrequency)}"
    : endswith(each.value.queryFrequency, "h")
    ? "PT${upper(each.value.queryFrequency)}"
    : each.value.queryFrequency
  )

  query_period = (
    endswith(each.value.queryPeriod, "m")
    ? "PT${upper(each.value.queryPeriod)}"
    : endswith(each.value.queryPeriod, "h")
    ? "PT${upper(each.value.queryPeriod)}"
    : each.value.queryPeriod
  )

  ############################################
  # Alert threshold
  ############################################

  trigger_operator  = "GreaterThan"
  trigger_threshold = each.value.triggerThreshold

  ############################################
  # MITRE ATT&CK
  ############################################

  tactics = try(
    each.value.tactics,
    []
  )

  techniques = try(
    each.value.relevantTechniques,
    []
  )

  ############################################
  # Incident creation and grouping
  ############################################

  incident {
    create_incident_enabled = true

    grouping {
      enabled                 = true
      reopen_closed_incidents = false
      lookback_duration       = "PT1H"
      entity_matching_method  = "AnyAlert"
    }
  }

  ############################################
  # Sentinel Entity Mapping
  #
  # Creates entity mappings only where they
  # are defined in the YAML rule.
  ############################################

  dynamic "entity_mapping" {
    for_each = try(
      each.value.entityMappings,
      []
    )

    content {
      entity_type = entity_mapping.value.entityType

      dynamic "field_mapping" {
        for_each = entity_mapping.value.fieldMappings

        content {
          identifier  = field_mapping.value.identifier
          column_name = field_mapping.value.columnName
        }
      }
    }
  }

  ############################################
  # Ensure Sentinel has been onboarded first
  ############################################

  depends_on = [
    azurerm_sentinel_log_analytics_workspace_onboarding.main
  ]
}