resource "random_pet" "lb_hostname" {
}

resource "azurerm_resource_group" "rg" {
  name     = "day14-rg"
  location = "canadacentral"
}

resource "azurerm_virtual_network" "test" {
  name                = "terrafrom-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.0.0/20"]
}

resource "azurerm_network_security_group" "myNSG" {
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
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow-ssh"
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
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.myNSG.id
}

#public ip for load balancer
resource "azurerm_public_ip" "public_ip" {
  name                = "lb-publicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  domain_name_label   = "${azurerm_resource_group.rg.name}-${random_pet.lb_hostname.id}"
}

#loadbalancer
resource "azurerm_lb" "loadbalancer" {
  name                = "myLB"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "myPublicIP"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}

#backend address pool
resource "azurerm_lb_backend_address_pool" "bepool" {
  name            = "myBackendAddressPool"
  loadbalancer_id = azurerm_lb.loadbalancer.id
}

#loadbalancer probe
resource "azurerm_lb_probe" "lb_probe" {
  name            = "http-probe"
  loadbalancer_id = azurerm_lb.loadbalancer.id
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}

#loadbalancer rule 
resource "azurerm_lb_rule" "lb_rule" {
  name                           = "http"
  loadbalancer_id                = azurerm_lb.loadbalancer.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "myPublicIP"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bepool.id]
  probe_id                       = azurerm_lb_probe.lb_probe.id
}

resource "azurerm_lb_nat_rule" "nat_rule_ssh" {
  name                           = "ssh"
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.loadbalancer.id
  protocol                       = "Tcp"
  frontend_port_start            = 50001
  frontend_port_end              = 50119
  backend_port                   = 22
  frontend_ip_configuration_name = "myPublicIP"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bepool.id
}

resource "azurerm_public_ip" "natgwpip" {
  name                = "nat-gw-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}

resource "azurerm_nat_gateway" "natgw" {
  name                    = "nat-Gateway"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

resource "azurerm_nat_gateway_public_ip_association" "natgw_pip_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.natgw.id
  public_ip_address_id = azurerm_public_ip.natgwpip.id
}

resource "azurerm_subnet_nat_gateway_association" "subnet_natgw_assoc" {
  subnet_id      = azurerm_subnet.subnet1.id
  nat_gateway_id = azurerm_nat_gateway.natgw.id
} 
