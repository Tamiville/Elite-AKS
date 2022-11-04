locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Service     = "DevOps"
    Company     = "Elitesolutionsit"
    Owner       = "Tamiville"
    environment = var.environment
    ManagedWith = "Terraform"

  }

  buildregion = var.buildregion
  #   SubcriptionName                  = var.SubcriptionName
  azurecontainerrgistry            = "eliteclusterdemo-devregistry"
  azurekubernetesrg                = "eliteclusterdemo-devrg"
  cluster_name                     = "eliteclusterdemodev"
  log_analytics_workspace_location = "centralus"
  log_analytics_workspace_name     = "eliteclusterdemoAnalytics"
}