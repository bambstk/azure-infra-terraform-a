variable "owner" { type = string }
variable "resource_group_name" { type = string }
variable "service_plan_id" { type = string }
variable "tags" { type = map(string) }
variable "location" { type = string }
variable "app_insights_connection_string" {
  type      = string
  sensitive = true
}
variable "app_settings" {
  description = "Application settings"
  type        = map(string)
  default     = {}
}
