output "service_principal_object_id" {
  value = azuread_service_principal.main.object_id
}

output "service_principal_tenant_id" {
  value = azuread_service_principal.main.application_tenant_id
}

output "client_id" {
  value = azuread_application.main.client_id
}

output "client_secret" {
  value = azuread_service_principal_password.main.value
  sensitive = true
}