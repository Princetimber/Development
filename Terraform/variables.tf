variable "resource_group_name" {
  default = "azuksterraformrg"
}
variable "storage_account_name" {
  default = "azuksterraformrgstga"
}
variable "location" {
  default = "uksouth"
}
variable "account_tier" {
  default = "Standard"
}
variable "account_replication_type" {
  default = "LRS"
}
variable "account_kind" {
  default = "StorageV2"
}
variable "enable_https_traffic_only" {
  default = true
}
variable "access_tier" {
  default = "Hot"
}
variable "allow_nested_items_to_be_public" {
  default = true
}
variable "change_feed_enabled" {
  default = true
}
variable "change_feed_retention_in_days" {
  default = 30
}
variable "container_delete_retention_policy_days" {
  default = 90
}
variable "default_service_version" {
  default = "2020-06-12"
}
variable "versioning_enabled" {
  default = true
}
variable "last_access_time_enabled" {
  default = true
}
