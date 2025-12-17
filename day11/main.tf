locals {
    formatted_name = lower(replace(var.project_name, " ", "-")) // 1 - to lower the case and replace spaces with hyphens
    merge_tags = merge(var.default_tags, var.env_tags) // 2 - to merge the tags
    storage_formatted = replace(replace(replace(lower(substr(var.storage_account_name,0,23)), " ", ""), "!", ""), "1", "i") // 3 - to ensure storage account name length limit
    formatted_ports = split(var.allowed_ports, ",") // 4 - to hold the allowed ports list
    nsg_rules = join("-", [for port in local.formatted_ports :  "port-${port}"])
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.formatted_name}-rg"
  location = "West Europe"
  tags     = local.merge_tags
}

resource "azurerm_storage_account" "example" {
  name                     = local.storage_formatted // 3 - using the formatted storage account name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = local.merge_tags
}

resource "azurerm_network_security_group" "example" {
  name                = var.environment == "dev" ? "dev-nsg" : "stage-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Here's where we need the dynamic block
  dynamic "security_rule" {
    for_each = local.nsg_rules
    content {
      name                       = security_rule.key
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range         = "*"
      destination_port_range    = security_rule.value.destination_port_range
      source_address_prefix     = "*"
      destination_address_prefix = "*"
      description               = security_rule.value.description
    }
  }
}

output "rg_name"{
    value = azurerm_resource_group.rg.name
}
output "storage_account_name"{
    value = azurerm_storage_account.example.name
}