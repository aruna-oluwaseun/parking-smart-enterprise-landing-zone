##############################################
# Allowed Azure locations policy definition
##############################################

resource "azurerm_policy_definition" "allowed_locations" {
  name         = "parkingsmart-allowed-locations"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Parking Smart - Audit allowed Azure locations"
  description  = "Audits resources deployed outside the approved Azure regions."

  metadata = jsonencode({
    category = "Parking Smart Governance"
    version  = "1.0.0"
  })

  parameters = jsonencode({
    allowedLocations = {
      type = "Array"

      metadata = {
        displayName = "Allowed locations"
        description = "Azure regions approved for Parking Smart resources."
        strongType  = "location"
      }

      defaultValue = [
        "uksouth"
      ]
    }

    effect = {
      type = "String"

      metadata = {
        displayName = "Effect"
        description = "Controls whether the policy audits, denies or is disabled."
      }

      allowedValues = [
        "Audit",
        "Deny",
        "Disabled"
      ]

      defaultValue = "Audit"
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "location"
          notIn = "[parameters('allowedLocations')]"
        },
        {
          field     = "location"
          notEquals = "global"
        }
      ]
    }

    then = {
      effect = "[parameters('effect')]"
    }
  })
}

##############################################
# Allowed Azure locations policy assignment
##############################################

resource "azurerm_subscription_policy_assignment" "allowed_locations" {
  name                 = "parkingsmart-allowed-locations"
  subscription_id      = "/subscriptions/${var.subscription_id}"
  policy_definition_id = azurerm_policy_definition.allowed_locations.id
  display_name         = "Parking Smart - Audit allowed Azure locations"
  description          = "Audits Azure resources deployed outside UK South."

  parameters = jsonencode({
    allowedLocations = {
      value = [
        "uksouth"
      ]
    }

    effect = {
      value = "Audit"
    }
  })
}

##############################################
# Required resource tags policy definition
##############################################

resource "azurerm_policy_definition" "required_tags" {
  name         = "parkingsmart-required-tags"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Parking Smart - Audit required resource tags"
  description  = "Audits resources that are missing required governance tags."

  metadata = jsonencode({
    category = "Parking Smart Governance"
    version  = "1.0.0"
  })

  parameters = jsonencode({
    effect = {
      type = "String"

      metadata = {
        displayName = "Effect"
        description = "Controls whether missing tags are audited or ignored."
      }

      allowedValues = [
        "Audit",
        "Disabled"
      ]

      defaultValue = "Audit"
    }
  })

  policy_rule = jsonencode({
    if = {
      anyOf = [
        {
          field  = "tags['Environment']"
          exists = "false"
        },
        {
          field  = "tags['Project']"
          exists = "false"
        },
        {
          field  = "tags['Owner']"
          exists = "false"
        },
        {
          field  = "tags['ManagedBy']"
          exists = "false"
        },
        {
          field  = "tags['CostCentre']"
          exists = "false"
        }
      ]
    }

    then = {
      effect = "[parameters('effect')]"
    }
  })
}

##############################################
# Required resource tags policy assignment
##############################################

resource "azurerm_subscription_policy_assignment" "required_tags" {
  name                 = "parkingsmart-required-tags"
  subscription_id      = "/subscriptions/${var.subscription_id}"
  policy_definition_id = azurerm_policy_definition.required_tags.id
  display_name         = "Parking Smart - Audit required resource tags"
  description          = "Audits resources missing the required Parking Smart governance tags."

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}