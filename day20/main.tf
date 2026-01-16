resource "azurerm_resource_group" "rg" {
  name     = var.rgname
  location = var.location
}

module "ServicePrincipal" {
  source                 = "./modules/ServicePrincipal"
  depends_on             = [azurerm_resource_group.rg]
  service_principal_name = var.service_principal_name
}

resource "azurerm_role_assignment" "rolespn" {
  scope                = "/subscriptions/c9136336-e35d-4e4f-8651-52180470889c"
  role_definition_name = "Contributor"
  principal_id         = module.ServicePrincipal.service_principal_object_id

  depends_on = [module.ServicePrincipal]
}

module "keyvault" {
  source                      = "./modules/keyvault"
  keyvault_name               = var.keyvault_name
  location                    = var.location
  resource_group_name         = var.rgname
  service_principal_name      = var.service_principal_name
  service_principal_object_id = module.ServicePrincipal.service_principal_object_id
  service_principal_tenant_id = module.ServicePrincipal.service_principal_tenant_id

  depends_on = [module.ServicePrincipal]
}

# Grant the service principal permission to manage Key Vault secrets
resource "azurerm_role_assignment" "keyvault_secrets_officer" {
  scope                = module.keyvault.keyvault_id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = module.ServicePrincipal.service_principal_object_id

  depends_on = [module.keyvault]
}

resource "azurerm_key_vault_secret" "example" {
  name         = module.ServicePrincipal.client_id
  value        = module.ServicePrincipal.client_secret
  key_vault_id = module.keyvault.keyvault_id

  depends_on = [azurerm_role_assignment.keyvault_secrets_officer]
}

module "aks" {
  source                 = "./modules/aks"
  service_principal_name = var.service_principal_name
  client_id              = module.ServicePrincipal.client_id
  client_secret          = module.ServicePrincipal.client_secret
  location               = var.location
  resource_group_name    = var.rgname

  depends_on = [module.ServicePrincipal]
}
