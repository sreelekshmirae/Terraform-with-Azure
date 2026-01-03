# variable "prefix" {
#   default = "day17"
#   type    = string
# }

# resource "azurerm_resource_group" "rg" {
#   name     = "${var.prefix}-rg"
#   location = "canadacentral"
# }

# #app service plan

# resource "azurerm_service_plan" "asp" {
#   name                = "${var.prefix}-asp"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   sku_name            = "S1"
#   os_type             = "Linux"
# }

# #linux webapp

# resource "azurerm_linux_web_app" "name" {
#   name                = "${var.prefix}-webapp17"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_service_plan.asp.location
#   service_plan_id     = azurerm_service_plan.asp.id

#   site_config {}
# }

# #deployment slot

# resource "azurerm_linux_web_app_slot" "webappslot" {
#   name           = "${var.prefix}-webappslot"
#   app_service_id = azurerm_linux_web_app.name.id

#   site_config {}
# }

# #source control

# resource "azurerm_linux_web_app_source_control" "scm1" {
#   repo_url = "https://github.com/sreelekshmirae/sample-webapp-azure.git"
#   branch   = "appServiceSlot_Working_DO_NOT_MERGE"
# }

# #swap the slots

# resource "azurerm_web_app_active_slot" "active" {
#   slot_id = azurerm_linux_web_app_slot.webappslot.id
# }