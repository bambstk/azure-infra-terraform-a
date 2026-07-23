terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# le appservice ?

resource "azurerm_linux_web_app" "app" {
  name                = "app-${var.owner}-tf-dvlp"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id
  https_only          = "true"

  site_config {
    minimum_tls_version = "1.2"
    application_stack {
      python_version = "3.11"
    }
    health_check_path                 = "/health"        # route Flask existante
    health_check_eviction_time_in_min = 10
  }
  app_settings = merge(var.app_settings, {
      "APPLICATIONINSIGHTS_CONNECTION_STRING"      = var.app_insights_connection_string
      "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    })

  tags = var.tags
}

# Indice : pour récupérer la location du plan partagé à partir de son ID,
# utilisez un data source azurerm_service_plan avec split("/", var.service_plan_id)
