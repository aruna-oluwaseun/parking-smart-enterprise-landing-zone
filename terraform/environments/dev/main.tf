##############################################
# Platform Resource Group
##############################################

resource "azurerm_resource_group" "platform" {
  name     = local.resource_groups.platform
  location = var.location

  tags = local.common_tags
}

##############################################
# Networking Resource Group
##############################################

resource "azurerm_resource_group" "networking" {
  name     = local.resource_groups.networking
  location = var.location

  tags = local.common_tags
}

##############################################
# Monitoring Resource Group
##############################################

resource "azurerm_resource_group" "monitoring" {
  name     = local.resource_groups.monitoring
  location = var.location

  tags = local.common_tags
}

##############################################
# Security Resource Group
##############################################

resource "azurerm_resource_group" "security" {
  name     = local.resource_groups.security
  location = var.location

  tags = local.common_tags
}

##############################################
# Workloads Resource Group
##############################################

resource "azurerm_resource_group" "workloads" {
  name     = local.resource_groups.workloads
  location = var.location

  tags = local.common_tags
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${local.name_prefix}"
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name

  sku               = "PerGB2018"
  retention_in_days = 30

  tags = local.common_tags
}

##############################################
# Hub Virtual Network
##############################################

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-${local.name_prefix}-hub"
  location            = azurerm_resource_group.networking.location
  resource_group_name = azurerm_resource_group.networking.name
  address_space       = var.hub_vnet_address_space

  tags = local.common_tags
}

##############################################
# Application Spoke Virtual Network
##############################################

resource "azurerm_virtual_network" "application_spoke" {
  name                = "vnet-${local.name_prefix}-application"
  location            = azurerm_resource_group.networking.location
  resource_group_name = azurerm_resource_group.networking.name
  address_space       = var.application_vnet_address_space

  tags = local.common_tags
}

##############################################
# Hub Subnet
##############################################

resource "azurerm_subnet" "hub_management" {
  name                 = "snet-management"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hub_management_subnet_prefix]
}

##############################################
# Application Spoke Subnets
##############################################

resource "azurerm_subnet" "application" {
  name                 = "snet-application"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.application_spoke.name
  address_prefixes     = [var.spoke_application_subnet_prefix]
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.application_spoke.name
  address_prefixes     = [var.spoke_aks_subnet_prefix]
}

##############################################
# Hub Management NSG
##############################################

resource "azurerm_network_security_group" "hub_management" {
  name                = "nsg-${local.name_prefix}-hub-management"
  location            = azurerm_resource_group.networking.location
  resource_group_name = azurerm_resource_group.networking.name

  security_rule {
    name                       = "AllowVNetInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  tags = local.common_tags
}

##############################################
# Application NSG
##############################################

resource "azurerm_network_security_group" "application" {
  name                = "nsg-${local.name_prefix}-application"
  location            = azurerm_resource_group.networking.location
  resource_group_name = azurerm_resource_group.networking.name

  security_rule {
    name                       = "AllowHubInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.hub_vnet_address_space[0]
    destination_address_prefix = var.application_vnet_address_space[0]
  }

  tags = local.common_tags
}

