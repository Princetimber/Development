output "name" {
  value = azurerm_resource_group.rg
}
output "location" {
  value = azurerm_resource_group.rg.location
}
output "id" {
  value = azurerm_resource_group.rg.id
  sensitive = true
}
output "tags" {
  value = azurerm_resource_group.rg.tags
}
output "stgname" {
  value = azurerm_storage_account.stg
  sensitive = true
}
output "stglocation" {
  value = azurerm_storage_account.stg.location
}
output "stgid" {
  value = azurerm_storage_account.stg.id
  sensitive = true
}
