


# resourcec group name
output "resource_group_name" {
  value       = azurerm_resource_group.rg-application.name
  description = "Resource group name"
}


output "azurerm_container_app_url_frontend" {
  value = azurerm_container_app.frontend.ingress[0].fqdn
}

output "azurerm_container_app_url_backend" {
  value = azurerm_container_app.backend-private.ingress[0].fqdn
}

output "azurerm_container_app_url_backend_private" {
  value = azurerm_container_app.backend-private.ingress[0].fqdn
}