terraform {
  backend "azurerm" {
    resource_group_name  = "rg-parkingsmart-tfstate-platform"
    storage_account_name = "stparkingsmarttfqzp36r"
    container_name       = "tfstate"
    key                  = "landing-zone/dev/terraform.tfstate"
    use_azuread_auth     = true
    use_cli              = true
  }
}