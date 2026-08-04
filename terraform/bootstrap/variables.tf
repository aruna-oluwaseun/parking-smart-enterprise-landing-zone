variable "subscription_id" {
  description = "Azure subscription ID used for the landing-zone project."
  type        = string
}

variable "location" {
  description = "Azure region for Terraform state resources."
  type        = string
  default     = "uksouth"
}

variable "project_name" {
  description = "Short project identifier."
  type        = string
  default     = "parkingsmart"
}

variable "environment" {
  description = "Environment represented by the state infrastructure."
  type        = string
  default     = "platform"
}