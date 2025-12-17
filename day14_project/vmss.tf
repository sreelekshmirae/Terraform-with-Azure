resource "azurerm_orchestrated_virtual_machine_scale_set" "vmss_terraform" {
    name = "vmss-terraform"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    sku_name = "Standard_DS1_v2"
    instances = 3
    platform_fault_domain_count = 1
    zone = ["1"]

    user_data_base64 = base64encode(file("user-data.sh"))  //this is the data that run once the VM is created 
    os_profile {
        linux_configuration {
            disable_password_authentication = true
            admin_username = "azureuser"
            admin_ssh_key {
                username = "azureuser"
                public_key = file(".ssh/key.pub")
        }
    }
}