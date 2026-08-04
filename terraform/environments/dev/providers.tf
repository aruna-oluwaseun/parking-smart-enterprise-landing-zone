provider "azurerm" {
  features {}

  subscription_id = var.subscription_id

  # Resource providers will be registered explicitly rather than
  # automatically by Terraform.
  resource_provider_registrations = "none"
}