resource "random_string" "storage_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "terraform_state" {
  name     = "rg-${var.project_name}-tfstate-${var.environment}"
  location = var.location

  tags = {
    project     = "Parking Smart Enterprise Landing Zone"
    environment = var.environment
    managed_by  = "Terraform"
    purpose     = "Terraform remote state"
  }
}

resource "azurerm_storage_account" "terraform_state" {
  name = substr(
    lower("st${var.project_name}tf${random_string.storage_suffix.result}"),
    0,
    24
  )

  resource_group_name      = azurerm_resource_group.terraform_state.name
  location                 = azurerm_resource_group.terraform_state.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }
  }

  tags = azurerm_resource_group.terraform_state.tags
}

resource "azurerm_storage_container" "terraform_state" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.terraform_state.id
  container_access_type = "private"
}