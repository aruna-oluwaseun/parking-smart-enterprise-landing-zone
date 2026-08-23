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

##############################################
# IOC Enrichment Logic App
##############################################

resource "azurerm_logic_app_workflow" "enrich_ioc" {
  count = var.deploy_sentinel ? 1 : 0

  name                = "logic-${local.name_prefix}-enrich-ioc"
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name

  enabled = true

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

##############################################
# IOC Enrichment Request Trigger
##############################################

resource "azurerm_logic_app_trigger_http_request" "enrich_ioc" {
  count = var.deploy_sentinel ? 1 : 0

  name         = "When_IOC_Enrichment_Is_Requested"
  logic_app_id = azurerm_logic_app_workflow.enrich_ioc[0].id

  schema = jsonencode({
    type = "object"

    properties = {
      indicator = {
        type = "string"
      }

      indicatorType = {
        type = "string"
      }

      incidentId = {
        type = "string"
      }
    }

    required = [
      "indicator",
      "indicatorType"
    ]
  })
}

##############################################
# Build IOC Enrichment Payload
##############################################

resource "azurerm_logic_app_action_custom" "enrich_ioc_payload" {
  count = var.deploy_sentinel ? 1 : 0

  name         = "Build_IOC_Enrichment_Payload"
  logic_app_id = azurerm_logic_app_workflow.enrich_ioc[0].id

  body = jsonencode({
    type = "Compose"

    inputs = {
      indicator     = "@triggerBody()?['indicator']"
      indicatorType = "@triggerBody()?['indicatorType']"
      incidentId    = "@triggerBody()?['incidentId']"

      enrichmentStatus = "Enrichment requested"
    }

    runAfter = {}
  })
}
##############################################
# Disable Account Logic App
##############################################

resource "azurerm_logic_app_workflow" "disable_account" {
  count = var.deploy_sentinel ? 1 : 0

  name                = "logic-${local.name_prefix}-disable-account"
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name

  enabled = true

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

##############################################
# Disable Account Request Trigger
##############################################

resource "azurerm_logic_app_trigger_http_request" "disable_account" {
  count = var.deploy_sentinel ? 1 : 0

  name         = "When_Account_Disable_Is_Requested"
  logic_app_id = azurerm_logic_app_workflow.disable_account[0].id

  schema = jsonencode({
    type = "object"

    properties = {
      userId = {
        type = "string"
      }

      userPrincipalName = {
        type = "string"
      }

      incidentId = {
        type = "string"
      }

      reason = {
        type = "string"
      }
    }

    required = [
      "userId",
      "incidentId"
    ]
  })
}

##############################################
# Build Account Containment Payload
##############################################

resource "azurerm_logic_app_action_custom" "disable_account_payload" {
  count = var.deploy_sentinel ? 1 : 0

  name         = "Build_Account_Containment_Payload"
  logic_app_id = azurerm_logic_app_workflow.disable_account[0].id

  body = jsonencode({
    type = "Compose"

    inputs = {
      userId            = "@triggerBody()?['userId']"
      userPrincipalName = "@triggerBody()?['userPrincipalName']"
      incidentId        = "@triggerBody()?['incidentId']"
      reason            = "@triggerBody()?['reason']"

      containmentAction = "Disable account"
      containmentStatus = "Requested"
    }

    runAfter = {}
  })
}

##############################################
# Create Incident Logic App
##############################################

resource "azurerm_logic_app_workflow" "create_incident" {
  count = var.deploy_sentinel ? 1 : 0

  name                = "logic-${local.name_prefix}-create-incident"
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name

  enabled = true

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

##############################################
# Create Incident Request Trigger
##############################################

resource "azurerm_logic_app_trigger_http_request" "create_incident" {
  count = var.deploy_sentinel ? 1 : 0

  name         = "When_Incident_Creation_Is_Requested"
  logic_app_id = azurerm_logic_app_workflow.create_incident[0].id

  schema = jsonencode({
    type = "object"

    properties = {
      incidentTitle = {
        type = "string"
      }

      severity = {
        type = "string"
      }

      description = {
        type = "string"
      }

      source = {
        type = "string"
      }
    }

    required = [
      "incidentTitle",
      "severity"
    ]
  })
}

##############################################
# Build Incident Payload
##############################################

resource "azurerm_logic_app_action_custom" "create_incident_payload" {
  count = var.deploy_sentinel ? 1 : 0

  name         = "Build_Incident_Payload"
  logic_app_id = azurerm_logic_app_workflow.create_incident[0].id

  body = jsonencode({
    type = "Compose"

    inputs = {
      incidentTitle = "@triggerBody()?['incidentTitle']"
      severity      = "@triggerBody()?['severity']"
      description   = "@triggerBody()?['description']"
      source        = "@triggerBody()?['source']"

      requestedAction = "Create Sentinel incident"
      requestStatus   = "Requested"
    }

    runAfter = {}
  })
}