resource "azurerm_resource_group" "rg" {
  name     = "day15-rg1"
  location = "canadacentral"
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "peer-vnet1"
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "sn1" {
  name                 = "peer-sn1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.0.0/24"]

}

resource "azurerm_virtual_network" "vnet2" {
  name                = "peer-vnet2"
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.1.0.0/16"]
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "sn2" {
  name                 = "peer-sn2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = ["10.1.1.0/24"]
}

#--------PEERING------------

resource "azurerm_virtual_network_peering" "peer1" {
  name                      = "peer1to2"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet1.name
  remote_virtual_network_id = azurerm_virtual_network.vnet2.id
}

resource "azurerm_virtual_network_peering" "peer2" {
  name                      = "peer2to1"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet2.name
  remote_virtual_network_id = azurerm_virtual_network.vnet1.id
}

