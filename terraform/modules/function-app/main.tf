terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# La Function App a besoin d'un storage account propre (obligatoire Azure).
# Ce storage est SÉPARÉ du storage métier du module storage/.

resource "azurerm_storage_account" "fn_storage" {
  name                     = "stfn8${replace(var.owner, "-", "")}8tf8dvlp"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}

# créer un azurerm_linux_function_app

resource "azurerm_linux_function_app" "fn" {
  name                       = "fn-${var.owner}-tf-dvlp"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  service_plan_id            = var.service_plan_id
  storage_account_name       = azurerm_storage_account.fn_storage.name
  storage_account_access_key = azurerm_storage_account.fn_storage.primary_access_key

  site_config {
    application_stack {
      python_version = "3.11"
    }
    health_check_path                 = "/api/http_trigger"   # la Function App n'a pas /health
    health_check_eviction_time_in_min = 10
  }
  app_settings = merge(var.app_settings, {
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.app_insights_connection_string
    })

  tags = var.tags
}
