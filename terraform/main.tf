# ──────────────────────────────────────────────────────────────────────────────
# main.tf — Ressources Azure à provisionner avec Terraform
#
# Ce fichier est votre point d'entrée. Complétez les TODO au fil du TP.
# ──────────────────────────────────────────────────────────────────────────────

# ── Tags communs à toutes les ressources ──────────────────────────────────────
# Ces tags sont mergés automatiquement dans chaque module via var.tags

locals {
  tags = merge(
    {
      managed_by  = "terraform"
      environment = "tp"
      owner       = var.owner
      gang        = "disco-empañada-super-ultra-megakill-dos-tres-quatro-dvlpdvlpdvlp-afterlife"
    },
    var.tags
  )
}

# ── Data sources ──────────────────────────────────────────────────────────────
# Un data source LIT une ressource existante sans la créer.

# Resource Group pré-créé par le formateur — ne jamais le gérer en Terraform
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Plan App Service partagé (dans un Resource Group séparé)
data "azurerm_service_plan" "shared" {
  name                = var.shared_plan_name
  resource_group_name = var.shared_rg_name
}

# ── Storage (Étape 2) ─────────────────────────────────────────────────────────

module "storage" {
  source = "./modules/storage"

  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  tags                = local.tags
}

# ── App Service (Étape 3) ─────────────────────────────────────────────────────

module "app_service" {
  source                         = "./modules/app-service"
  app_insights_connection_string = module.observability.app_insights_connection_string
  owner                          = var.owner
  resource_group_name            = data.azurerm_resource_group.rg.name
  service_plan_id                = data.azurerm_service_plan.shared.id
  location                       = var.location
  tags                           = local.tags
}

# ── Function App (Étape 3) ────────────────────────────────────────────────────

module "function_app" {
  source                         = "./modules/function-app"
  app_insights_connection_string = module.observability.func_insights_connection_string
  owner                          = var.owner
  resource_group_name            = data.azurerm_resource_group.rg.name
  location                       = var.location
  service_plan_id                = data.azurerm_service_plan.shared.id
  tags                           = local.tags
}

# ── Container Instance (Étape 3) ──────────────────────────────────────────────

module "container" {
  source = "./modules/container"

  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  tags                = local.tags
}

# ── Network (Étape 7) ─────────────────────────────────────────────────────────
# appeler le module "./modules/network"

module "network" {
  source = "./modules/network"

  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  tags                = local.tags
}

# ── Observabilité (Étape tp-observabilité) ─────────────────────────────────────────────────────────
# appeler le module "./modules/observability"

module "observability" {
  source = "./modules/observability"

  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags                = local.tags

  app_service_id     = module.app_service.app_service_id
  function_app_id    = module.function_app.function_app_id
  storage_account_id = module.storage.storage_account_id

  app_service_url  = "https://${module.app_service.default_hostname}"
  function_app_url = "https://${module.function_app.default_hostname}"

  alert_email = "ton.email@example.com"
}