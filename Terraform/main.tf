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
