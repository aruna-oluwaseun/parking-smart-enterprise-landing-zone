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

      isPrivileged = {
        type = "boolean"
      }
    }

    required = [
      "userId",
      "incidentId",
      "isPrivileged"
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

##############################################
# IOC Enrichment - Key Vault Access
##############################################

resource "azurerm_role_assignment" "enrich_ioc_key_vault_secrets_user" {
  count = var.deploy_sentinel ? 1 : 0

  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"

  principal_id = azurerm_logic_app_workflow.enrich_ioc[0].identity[0].principal_id
}

##############################################
# Retrieve VirusTotal API Key from Key Vault
##############################################

resource "azurerm_logic_app_action_custom" "get_virustotal_api_key" {
  count = var.deploy_sentinel ? 1 : 0

  name         = "Get_VirusTotal_API_Key"
  logic_app_id = azurerm_logic_app_workflow.enrich_ioc[0].id

  body = jsonencode({
    type = "Http"

    inputs = {
      method = "GET"

      uri = "https://${azurerm_key_vault.main.name}.vault.azure.net/secrets/virustotal-api-key?api-version=7.4"

      authentication = {
        type     = "ManagedServiceIdentity"
        audience = "https://vault.azure.net"
      }
    }

    runAfter = {
      Build_IOC_Enrichment_Payload = [
        "Succeeded"
      ]
    }
  })
}

##############################################
# VirusTotal IOC Lookup
##############################################

resource "azurerm_logic_app_action_custom" "virustotal_lookup" {
  count = var.deploy_sentinel ? 1 : 0

  name         = "VirusTotal_IOC_Lookup"
  logic_app_id = azurerm_logic_app_workflow.enrich_ioc[0].id

  body = jsonencode({
    type = "Http"

    inputs = {
      method = "GET"

      uri = "https://www.virustotal.com/api/v3/search?query=@{triggerBody()?['indicator']}"

      headers = {
        "x-apikey" = "@body('Get_VirusTotal_API_Key')?['value']"
      }
    }

    runAfter = {
      Get_VirusTotal_API_Key = [
        "Succeeded"
      ]
    }
  })
}

##############################################
# Parse VirusTotal Response
##############################################

resource "azurerm_logic_app_action_custom" "parse_virustotal_response" {
  count = var.deploy_sentinel ? 1 : 0

  name         = "Parse_VirusTotal_Response"
  logic_app_id = azurerm_logic_app_workflow.enrich_ioc[0].id

  body = jsonencode({
    type = "ParseJson"

    inputs = {
      content = "@body('VirusTotal_IOC_Lookup')"

      schema = {
        type = "object"

        properties = {
          data = {
            type = "array"

            items = {
              type = "object"

              properties = {
                id = {
                  type = "string"
                }

                type = {
                  type = "string"
                }

                attributes = {
                  type = "object"

                  properties = {
                    reputation = {
                      type = ["integer", "null"]
                    }

                    last_analysis_stats = {
                      type = ["object", "null"]

                      properties = {
                        harmless = {
                          type = ["integer", "null"]
                        }

                        malicious = {
                          type = ["integer", "null"]
                        }

                        suspicious = {
                          type = ["integer", "null"]
                        }

                        undetected = {
                          type = ["integer", "null"]
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    runAfter = {
      VirusTotal_IOC_Lookup = [
        "Succeeded"
      ]
    }
  })
}

##############################################
# Build IOC Enrichment Result
##############################################

resource "azurerm_logic_app_action_custom" "build_enrichment_result" {
  count = var.deploy_sentinel ? 1 : 0

  name         = "Build_IOC_Enrichment_Result"
  logic_app_id = azurerm_logic_app_workflow.enrich_ioc[0].id

  body = jsonencode({
    type = "Compose"

    inputs = {
      indicator = "@triggerBody()?['indicator']"

      indicatorType = "@triggerBody()?['indicatorType']"

      resultCount = "@length(body('Parse_VirusTotal_Response')?['data'])"

      firstResult = "@first(body('Parse_VirusTotal_Response')?['data'])"

      enrichmentProvider = "VirusTotal"

      enrichmentStatus = "Completed"
    }

    runAfter = {
      Parse_VirusTotal_Response = [
        "Succeeded"
      ]
    }
  })
}

##############################################
# VirusTotal Failure Handling
##############################################

resource "azurerm_logic_app_action_custom" "virustotal_failure" {
  count = var.deploy_sentinel ? 1 : 0

  name         = "Handle_VirusTotal_Failure"
  logic_app_id = azurerm_logic_app_workflow.enrich_ioc[0].id

  body = jsonencode({
    type = "Compose"

    inputs = {
      indicator = "@triggerBody()?['indicator']"

      enrichmentProvider = "VirusTotal"

      enrichmentStatus = "Failed"

      httpStatus = "@outputs('VirusTotal_IOC_Lookup')?['statusCode']"

      message = "VirusTotal enrichment could not be completed."

      investigationRequired = true
    }

    runAfter = {
      VirusTotal_IOC_Lookup = [
        "Failed",
        "TimedOut"
      ]
    }
  })
}

##############################################
# Write Enrichment Result to Sentinel Incident
##############################################

resource "azurerm_logic_app_action_custom" "write_enrichment_to_incident" {
  count = var.deploy_sentinel ? 1 : 0

  name         = "Write_Enrichment_To_Sentinel_Incident"
  logic_app_id = azurerm_logic_app_workflow.enrich_ioc[0].id

  body = jsonencode({
    type = "Http"

    inputs = {
      method = "PUT"

      uri = "https://management.azure.com/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.monitoring.name}/providers/Microsoft.OperationalInsights/workspaces/${azurerm_log_analytics_workspace.main.name}/providers/Microsoft.SecurityInsights/incidents/@{triggerBody()?['incidentId']}/comments/@{guid()}?api-version=2025-09-01"

      authentication = {
        type     = "ManagedServiceIdentity"
        audience = "https://management.azure.com/"
      }

      headers = {
        "Content-Type" = "application/json"
      }

      body = {
        properties = {
          message = "@{concat('IOC enrichment completed. Indicator: ', triggerBody()?['indicator'], '. Provider: VirusTotal. Result count: ', string(length(body('Parse_VirusTotal_Response')?['data'])))}"
        }
      }
    }

    runAfter = {
      Build_IOC_Enrichment_Result = [
        "Succeeded"
      ]
    }
  })
}

##############################################
# IOC Enrichment - Sentinel RBAC
##############################################

resource "azurerm_role_assignment" "enrich_ioc_sentinel_responder" {
  count = var.deploy_sentinel ? 1 : 0

  scope                = azurerm_log_analytics_workspace.main.id
  role_definition_name = "Microsoft Sentinel Responder"

  principal_id = azurerm_logic_app_workflow.enrich_ioc[0].identity[0].principal_id

}

##############################################
# Validate Account Containment
##############################################

resource "azurerm_logic_app_action_custom" "validate_account_containment" {
  count = var.deploy_sentinel ? 1 : 0

  name         = "Validate_Account_Containment"
  logic_app_id = azurerm_logic_app_workflow.disable_account[0].id

  body = jsonencode({
    type = "If"

    expression = {
      and = [
        {
          equals = [
            "@triggerBody()?['isPrivileged']",
            false
          ]
        }
      ]
    }

    actions = {}

    else = {
      actions = {
        Block_Privileged_Account_Disable = {
          type = "Compose"

          inputs = {
            status     = "Blocked"
            reason     = "Automatic containment is not permitted for privileged accounts."
            userId     = "@triggerBody()?['userId']"
            incidentId = "@triggerBody()?['incidentId']"
          }
        }
      }
    }

    runAfter = {
      Build_Account_Containment_Payload = [
        "Succeeded"
      ]
    }
  })
}


##############################################
# Disable Entra ID Account via Microsoft Graph
##############################################

resource "azurerm_logic_app_action_custom" "disable_entra_account" {
  count = var.deploy_sentinel ? 1 : 0

  name         = "Disable_Entra_Account"
  logic_app_id = azurerm_logic_app_workflow.disable_account[0].id

  body = jsonencode({
    type = "Http"

    inputs = {
      method = "PATCH"

      uri = "https://graph.microsoft.com/v1.0/users/@{triggerBody()?['userId']}"

      authentication = {
        type     = "ManagedServiceIdentity"
        audience = "https://graph.microsoft.com"
      }

      headers = {
        "Content-Type" = "application/json"
      }

      body = {
        accountEnabled = false
      }
    }

    runAfter = {
      Build_Account_Containment_Payload = [
        "Succeeded"
      ]
    }
  })
}
