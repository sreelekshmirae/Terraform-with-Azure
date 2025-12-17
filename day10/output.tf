output "rg_name" {
    value = azurerm_resource_group.example[*].name
}

output "storage_account_names" {
    value = [for i in azurerm_storage_account.example : i.name]
}