provider "azurerm" {
  environment = "Public"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    key_vault {
      purge_soft_delete_on_destroy                            = true
      purge_soft_deleted_certificates_on_destroy              = true
      purge_soft_deleted_hardware_security_modules_on_destroy = true
      purge_soft_deleted_keys_on_destroy                      = true
      purge_soft_deleted_secrets_on_destroy                   = true
    }
    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = true
      skip_shutdown_and_force_delete = false
    }
    network {
      relaxed_locking = true
    }
  }
}
resource "azurerm_resource_group" "rg" {
  location = "uksouth"
  name     = "azuksterraformrg"
  provider = azurerm
  tags = {
    "DisplayName" = "ResourceGroup"
    "CostCenter"  = "Engineering"
  }
}
resource "azurerm_storage_account" "stg" {
  account_replication_type        = "LRS"
  account_tier                    = "Standard"
  location                        = "uksouth"
  name                            = var.storage_account_name
  resource_group_name             = var.resource_group_name
  account_kind                    = "StorageV2"
  enable_https_traffic_only       = true
  access_tier                     = "Hot"
  allow_nested_items_to_be_public = true
  blob_properties {
    change_feed_enabled           = true
    change_feed_retention_in_days = 30
    container_delete_retention_policy {
      days = 90
    }
    default_service_version  = "2020-06-12"
    versioning_enabled       = true
    last_access_time_enabled = true
  }
}
