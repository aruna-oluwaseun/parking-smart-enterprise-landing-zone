variable "subscription_id" {
  description = "Azure subscription ID where the Dev landing zone will be deployed."
  type        = string
  sensitive   = true
}

variable "location" {
  description = "Primary Azure region for the Dev environment."
  type        = string
  default     = "uksouth"
}

variable "project_name" {
  description = "Short name used when naming Parking Smart resources."
  type        = string
  default     = "parkingsmart"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "The project name can contain only lowercase letters, numbers and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be dev, test or prod."
  }
}

variable "owner" {
  description = "Person or team responsible for the environment."
  type        = string
  default     = "platform-team"
}

variable "cost_centre" {
  description = "Cost-management identifier applied to Azure resources."
  type        = string
  default     = "portfolio"
}

variable "hub_vnet_address_space" {
  description = "Address space allocated to the hub virtual network."
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "application_vnet_address_space" {
  description = "Address space allocated to the application spoke virtual network."
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "hub_management_subnet_prefix" {
  description = "Address prefix for the hub management subnet."
  type        = string
  default     = "10.10.1.0/24"
}

variable "spoke_application_subnet_prefix" {
  description = "Address prefix for the application subnet."
  type        = string
  default     = "10.20.1.0/24"
}

variable "spoke_aks_subnet_prefix" {
  description = "Address prefix for the future AKS subnet."
  type        = string
  default     = "10.20.2.0/23"
}

variable "spoke_private_endpoint_subnet_prefix" {
  description = "Address prefix for private endpoints in the application spoke."
  type        = string
  default     = "10.20.4.0/24"
}

variable "aks_node_vm_size" {
  type    = string
  default = "Standard_D2as_v5"
}

variable "aks_system_node_count" {
  type    = number
  default = 1
}

variable "aks_service_cidr" {
  type    = string
  default = "10.30.0.0/16"
}

variable "aks_dns_service_ip" {
  description = "DNS service IP address used by Kubernetes."
  type        = string
  default     = "10.30.0.10"
}

variable "aks_pod_cidr" {
  description = "CIDR block used for pod networking."
  type        = string
  default     = "10.40.0.0/16"
}

variable "deploy_aks" {
  description = "Controls whether the AKS cluster is deployed."
  type        = bool
  default     = false
}

variable "deploy_sentinel" {
  description = "Controls whether Microsoft Sentinel is enabled."
  type        = bool
  default     = false
}