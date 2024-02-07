

resource "azurerm_container_app" "frontend" {
  name                         = "aca-${var.env}-frontend"
  container_app_environment_id = azurerm_container_app_environment.acaenv.id
  resource_group_name          = azurerm_resource_group.rg-application.name
  revision_mode                = "Single"

  ingress {
    target_port      = 80
    external_enabled = true
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  # Ignore assigned Custom Domain through Azure Portal
  lifecycle {
    ignore_changes = [
      ingress[0].custom_domain,
    ]
  }

  template {
    min_replicas = 0
    max_replicas = 5
    container {
      name   = "c-${var.env}-frontend"
      image  = "ghcr.io/andrejvysny/complex-fe:latest"
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name  = "BACKEND_HOST"
        value = "https://${azurerm_container_app.backend.ingress[0].fqdn}"
      }
      env {
        name  = "PRIVATE_BACKEND_HOST"
        value = "https://${azurerm_container_app.backend-private.ingress[0].fqdn}"
      }
      env {
        name  = "TEST_ENV"
        value = "example value"
      }
    }
  }

  tags = merge(
    local.default_tags,
    {
      purpose = "example"
    }
  )
}


resource "azurerm_container_app" "backend" {
  name                         = "aca-${var.env}-backend"
  container_app_environment_id = azurerm_container_app_environment.acaenv.id
  resource_group_name          = azurerm_resource_group.rg-application.name
  revision_mode                = "Single"

  ingress {
    target_port                = 8080
    allow_insecure_connections = true
    external_enabled           = true
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    min_replicas = 0
    max_replicas = 5
    container {
      name   = "c-${var.env}-backend"
      image  = "ghcr.io/andrejvysny/complex-be:latest"
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name  = "MESSAGE"
        value = "Public BACKEND - ENV message"
      }
    }
  }

  tags = merge(
    local.default_tags,
    {
      purpose = "example"
    }
  )
}




resource "azurerm_container_app" "backend-private" {
  name                         = "aca-${var.env}-backend-private"
  container_app_environment_id = azurerm_container_app_environment.acaenv.id
  resource_group_name          = azurerm_resource_group.rg-application.name
  revision_mode                = "Single"

  ingress {
    target_port                = 8080
    transport                  = "auto"
    allow_insecure_connections = false
    external_enabled           = false
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    min_replicas = 0
    max_replicas = 5
    container {
      name   = "c-${var.env}-backend-private"
      image  = "ghcr.io/andrejvysny/complex-be:latest"
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name  = "MESSAGE"
        value = "Private BACKEND - ENV message"
      }
    }
  }

  tags = merge(
    local.default_tags,
    {
      purpose = "example"
    }
  )
}
/*

################################ PRIVATE IMAGE REPOSITORY ##################################x


# Key vault needs to exist in Azure -> only reading secret
data "azurerm_key_vault" "default_key_vault" {
  name                = "default-key-vault"      # Change to your data
  resource_group_name = "default-resource-group" # Change to your data
}

data "azurerm_key_vault_secret" "github_acces_token_secret" {
  name         = "github-access-token" # Change to your data
  key_vault_id = data.azurerm_key_vault.default_key_vault.id
}


resource "azurerm_container_app" "private_image_example" {
  name                         = "private-image-example"
  container_app_environment_id = azurerm_container_app_environment.acaenv.id
  resource_group_name          = azurerm_resource_group.rg-application.name
  revision_mode                = "Single"

  ingress {
    target_port                = 80
    allow_insecure_connections = true
    external_enabled           = true
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  registry {
    server               = "ghcr.io"
    username             = "andrejvysny"
    password_secret_name = "github-access-token"
  }

  secret {
    name  = "github-access-token"
    value = data.azurerm_key_vault_secret.github_acces_token_secret.value
  }

  template {
    container {
      name   = "c-${var.env}-private-image-example"
      image  = "ghcr.io/andrejvysny/nginx-hello-world-private:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  tags = local.default_tags
}

*/