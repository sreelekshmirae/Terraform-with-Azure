resource "random_pet" "lb_hostname" {
}

resource "azurerm_resource_group" "rg" {
  name     = "day14-rg"
  location = "canadacentral"
}

resource "azurerm_virtual_network" "test" {
  name                = "terrafrom-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.0.0/20"]
}

resource azurerm_network_security_group "myNSG" {
    name                = "myNSG"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    security_rule {
        name                       = "allow-http"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "allow-https"
        priority                   = 102
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_subnet_network_security_group_association" "myNSG" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.myNSG.id
}

#public ip for load balancer
resource "azurerm_public_ip" "example" {
    name                = "lb-publicIP"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method   = "Static"
    sku                 = "Standard"
    zone               = ["1", "2", "3"]
    domain_name_label = "${azurerm_resource_group.rg.name}-${random_pet.lb_hostname.id}"
} 

#loadbalancer
resource "azurerm_lb" "example" {
    name                = "myLB"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku                 = "Standard"
    frontend_ip_configuration {
        name                 = "myPublicIP"
        public_ip_address_id = azurerm_public_ip.example.id
    }
}

#backend address pool
resource "azurerm_lb_backend_address_pool" "bepool" {
    name                = "myBackendAddressPool"
    loadbalancer_id     = azurerm_lb.example.id
}

#loadbalancer rule 
resource "azurerm_lb_rule" "example" {
    name = "http"
    loadbalancer_id            = azurerm_lb.example.id
    protocol                   = "Tcp"
    frontend_port              = 80
    backend_port               = 80
    frontend_ip_configuration_name = "myPublicIP"
    backend_address_pool_id    = [azurerm_lb_backend_address_pool.bepool.id]
    probe_id                   = azurerm_lb_probe.example.id
}

resource "azurerm_public_ip" "natgwpip" {
    name = "natgw-publicIP"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method = "Static"
    sku = "Standard"
    zone = ["1"]
}

