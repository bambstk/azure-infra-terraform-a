terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# notamentle strogae account

resource "azurerm_storage_account" "sa" {
  name                            = "st8${replace(var.owner, "-", "")}8tf8dvlp"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = "true"   # true pour permettre api-config public
  tags                            = var.tags
}

# googoo gaga

resource "azurerm_storage_container" "api_logs" {
  name                  = "api-logs-dvlp"
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}

# gougougaga

resource "azurerm_storage_container" "api_config" {
  name                  = "api-config-dvlp"
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "blob"
}
