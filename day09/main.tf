resource "azurerm_resource_group" "example" {
  name     = "${var.environment}-resources"
  location = var.allowed_location[2]
}

resource "azurerm_storage_account" "example" {
  for_each                 = var.storage_account_name
  name                     = each.value
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }

  # lifecycle {
  #   create_before_destroy = false
  #   ignore_changes       = [tags]
  #   prevent_destroy       = true
    
  #   precondition {
  #     condition = contains(var.allowed_location, var.location)
  #     error_message = "The specified location is not allowed."
  #   }
  # }
}
