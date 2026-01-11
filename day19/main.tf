resource "azurerm_resource_group" "rg" {
  name     = "provisioner-day19"
  location = "East US"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "provisioner-vnet-day19"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "provisioner-subnet-day19"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "provisioner-nsg-day19"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "public_ip" {
  name                = "provisioner-public-ip-day19"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = "provisioner-nic-day19"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# PROVISIONER TO LOG DEPLOYMENT TIME

resource "null_resource" "deployment_prep" {
  triggers = {
    always_run = timestamp() #it runs every time
  }

  provisioner "local-exec" {
    command = "echo 'Deployment started at ${timestamp()}' > start_deployment_${timestamp()}.log"
  }

}


resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "provisioner-vm-day19"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = "Standard_B1s"
  network_interface_ids = [azurerm_network_interface.nic.id]

  depends_on = [null_resource.deployment_prep]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  computer_name                   = "provisionervmday19"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")

  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y nginx",
      "echo '<h1>Provisioned via Terraform</h1>' | sudo tee /var/www/html/index.html", #just for testing
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]

    connection {
      type        = "ssh"
      host        = azurerm_public_ip.public_ip.ip_address
      user        = "azureuser"
      private_key = file("~/.ssh/id_rsa")
    }
  }

  provisioner "file" {
    source      = "configs/localfile.conf"
    destination = "/home/azureuser/localfile.conf"

    connection {
      type        = "ssh"
      host        = azurerm_public_ip.public_ip.ip_address
      user        = "azureuser"
      private_key = file("~/.ssh/id_rsa")
    }
  }
}

# PROVISIONER TO LOG DEPLOYMENT finish TIME

resource "null_resource" "deployment_finish" {
  triggers = {
    always_run = timestamp() #it runs every time
  }

  provisioner "local-exec" {
    command = "echo 'Deployment finished at ${timestamp()}' >> finish_deployment_${timestamp()}.log"
  }
}

output "vm_public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}
