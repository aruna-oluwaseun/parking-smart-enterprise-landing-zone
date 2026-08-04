locals {
  name_prefix = "${var.project_name}-${var.environment}"

  resource_groups = {
    networking = "rg-${local.name_prefix}-networking"
    platform   = "rg-${local.name_prefix}-platform"
    security   = "rg-${local.name_prefix}-security"
    monitoring = "rg-${local.name_prefix}-monitoring"
    workloads  = "rg-${local.name_prefix}-workloads"
  }

  common_tags = {
    Project     = "Parking Smart"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner
    CostCentre  = var.cost_centre
    Repository  = "parking-smart-enterprise-landing-zone"
  }
}