terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# créer un Log Analytics Workspace (LAW)

resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-${var.owner}-tf-dvlp"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}


# créer les application insights, c'est des Application Performance Monitoring (APM) apparement

resource "azurerm_application_insights" "app" {
  name                = "appi-app-${var.owner}-tf-dvlp"
  resource_group_name = var.resource_group_name
  location            = var.location
  workspace_id        = azurerm_log_analytics_workspace.law.id   # ID du Log Analytics Workspace
  application_type    = "web"
  tags                = var.tags
}

resource "azurerm_application_insights" "func" {
  name                = "appi-func-${var.owner}-tf-dvlp"
  resource_group_name = var.resource_group_name
  location            = var.location
  workspace_id        = azurerm_log_analytics_workspace.law.id   # ID du Log Analytics Workspace
  application_type    = "web"
  tags                = var.tags
}


# alors là... trucs de diagnostiques ?

resource "azurerm_monitor_diagnostic_setting" "app_service" {
  name                       = "diag-app-${var.owner}-dvlp"
  target_resource_id         = var.app_service_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "func_app" {
  name                       = "diag-func-${var.owner}-dvlp"
  target_resource_id         = var.function_app_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "store_blob" {
  name                       = "diag-blob-${var.owner}-dvlp"
  target_resource_id         = "${var.storage_account_id}/blobServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  metric {
    category = "AllMetrics"
  }
}

# test de disponibilité selon les regions en gros

resource "azurerm_application_insights_standard_availability_test" "app_health" {
  name                    = "avail-app-${var.owner}-dvlp"
  resource_group_name     = var.resource_group_name
  location                = var.location
  application_insights_id = azurerm_application_insights.app.id
  geo_locations           = ["emea-fr-pra-edge", "emea-nl-ams-azr", "emea-gb-db3-azr"]
  frequency               = 300   # toutes les 5 minutes
  timeout                 = 30
  tags                    = var.tags

  request {
    url = "${var.app_service_url}/health"
  }

  validation_rules {
    expected_status_code = 200
  }
}

resource "azurerm_application_insights_standard_availability_test" "func_health" {
  name                    = "avail-func-${var.owner}-dvlp"
  resource_group_name     = var.resource_group_name
  location                = var.location
  application_insights_id = azurerm_application_insights.func.id
  geo_locations           = ["emea-fr-pra-edge", "emea-nl-ams-azr", "emea-gb-db3-azr"]
  frequency               = 300   # toutes les 5 minutes
  timeout                 = 30
  tags                    = var.tags

  request {
    url = "${var.func_service_url}/api/health"
  }

  validation_rules {
    expected_status_code = 200
  }
}

resource "azurerm_monitor_metric_alert" "app_availability" {
  name                = "alert-avail-app-${var.owner}"
  resource_group_name = var.resource_group_name
  scopes              = [
    azurerm_application_insights_standard_availability_test.app_health.id,
    azurerm_application_insights.app.id
  ]
  severity    = 0        # Critical
  frequency   = "PT1M"
  window_size = "PT5M"

  application_insights_web_test_location_availability_criteria {
    web_test_id           = azurerm_application_insights_standard_availability_test.app_health.id
    component_id          = azurerm_application_insights.app.id
    failed_location_count = 2   # alerte si 2 régions sur 3 échouent
  }

  action {
    action_group_id = azurerm_monitor_action_group.team.id
  }
}


resource "azurerm_monitor_action_group" "team" {
  name                = "ag-${var.owner}-tf"
  resource_group_name = var.resource_group_name
  short_name          = "team"

  email_receiver {
    name          = "equipe"
    email_address = var.alert_email
  }
}

resource "azurerm_monitor_metric_alert" "http5xx" {
  name                = "alert-http5xx-${var.owner}"
  resource_group_name = var.resource_group_name
  scopes              = [var.app_service_id]
  severity            = 1        # 0=Critical 1=Error 2=Warning
  frequency           = "PT1M"   # évaluation toutes les 1 min
  window_size         = "PT5M"   # fenêtre d'observation : 5 min

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 50
  }

  action {
    action_group_id = azurerm_monitor_action_group.team.id
  }
}