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
  }

  tags = var.tags
}

# Indice : pour récupérer la location du plan partagé à partir de son ID,
# utilisez un data source azurerm_service_plan avec split("/", var.service_plan_id)
