/*********************
 * SERVICE PRINCIPAL *
 *********************/
resource "azuread_application" "eliteclusterdemodev" {
  display_name = "eliteclusterdemodev"
}

resource "azuread_service_principal" "eliteclusterdemodev-SP" {
  application_id = azuread_application.eliteclusterdemodev.application_id
}

resource "azuread_service_principal_password" "eliteclusterdemodev-SP" {
  service_principal_id = azuread_service_principal.eliteclusterdemodev-SP.id
}

# /******************
#  * RESOURCE GROUP *
#  ******************/
resource "azurerm_resource_group" "eliteclusterdemorg" {
  name     = local.azurekubernetesrg
  location = local.buildregion
}

# /**********************
#  * ANALYTIC WORKSPACE *
#  **********************/
resource "random_id" "log_analytics_workspace_name_suffix" {
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "elitedemoAnalytics" {
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
  name                = "${local.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
  location            = local.log_analytics_workspace_location
  resource_group_name = local.azurekubernetesrg
  sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "elitedemoAnalytics" {
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.elitedemoAnalytics.location
  resource_group_name   = local.azurekubernetesrg
  workspace_resource_id = azurerm_log_analytics_workspace.elitedemoAnalytics.id
  workspace_name        = azurerm_log_analytics_workspace.elitedemoAnalytics.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

# /*******
#  * AKS *
#  *******/
resource "azurerm_kubernetes_cluster" "k8s" {
  name                = local.cluster_name
  location            = local.buildregion
  resource_group_name = local.azurekubernetesrg
  dns_prefix          = var.dns_prefix

# depends_on = [azurerm_resource_group.eliteclusterdemorg]

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCsUYl9+v2rmxJg1je66ENk2d7ccrN0ogPVwuzwAIYt0FIsmU6Ju/CKVdR94uZEKlWCkqiUYYvEoi8Ud6L6wr67eA46B6OIENZhJPCkKB95j5FluuWn5VCjL/5eJmgvfbbtbApUq69OgeWMNLVLoRSAkx381FbyGdxP6uzTjDCIrQ56Kz2TuDt5PDr9N78dHs8AyfGRnSV5er7i5uLTXRM/Zj3kosL8x/KALLg9di5q/zTwLoyGizF/pxHz2m5kkdf7e4kvH8PMGHYFCAydtVr0sgGT+7zeh4ptP3AS85NZqbJ9WhLU5BGXITprnn0oUU+l4AEO8bW6KOFMawwkFuSYBn1zbfeppIEWK71GT80Rs1GQis5f/OJEXa8DDYDeC+pZkrrd0CYnwUq8UcKLFo2zdMMTROezmCwFcyu8a+02LngmDy/jZcAskvrzx2A2sizdoUxZcWL0Wb+dS55e5v59aE8Q13vdmoWGZbp1L6q5hiVEG2VZrGAsmSVMexRyHfl2ybQssLpBQ7eJSL1xy/HAj9tPOLpgizJfjC6qXwul+524A9T8FJSK/60dPZcLPwPrLyK9OElog8hF2pbpPfBEak+3C+V+/+Vntwn8B7DP5mEr86i3WS8m13dyr/RxSR0Qprs2L4CHTsQddSJDXdzM2uNZNR6eOVuMPnFjpxr/2Q== devopslab@Tamie-Emmanuel"
    }
  }

  default_node_pool {
    name       = "agentpool"
    node_count = var.agent_count
    vm_size    = "Standard_D2_v2"
  }

  service_principal {
    client_id     = azuread_service_principal.eliteclusterdemodev-SP.application_id
    client_secret = azuread_service_principal_password.eliteclusterdemodev-SP.value
  }

  # addon_profile {
  #   oms_agent {
  #     enabled                    = true
  #     log_analytics_workspace_id = azurerm_log_analytics_workspace.elitedemoAnalytics.id
  #   }
  # }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "kubenet"
  }

  tags = local.common_tags
}

# /*************
#  * NAMESPACE *
#  *************/
# # Create Namespace
# resource "kubernetes_namespace" "eliteclusterdemo" {
#   metadata {
#     annotations = {
#       name = "eliteclusterdemo"
#     }

#     labels = {
#       mylabel = "eliteclusterdemo"
#     }

#     name = "eliteclusterdemo"
#   }
# }