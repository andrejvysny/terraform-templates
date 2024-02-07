

resource "azurerm_container_app" "frontend" {
  name                         = "aca-${var.env}-frontend"
  container_app_environment_id = azurerm_container_app_environment.acaenv.id
  resource_group_name          = azurerm_resource_group.rg-application.name
  revision_mode                = "Single"


  ingress {
    target_port                = 80
    external_enabled           = true
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
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
data "azurerm_key_vault" "my_first_app" {
  name                = "github-registry-access"
  resource_group_name = azurerm_resource_group.example.name
}

data "azurerm_key_vault_secret" "my_first_app_secret" {
  name         = "github-access-token"
  key_vault_id = data.azurerm_key_vault.my_first_app.id
}


resource "azurerm_container_app" "example-private" {
  name                         = "example-private"
  container_app_environment_id = azurerm_container_app_environment.example.id
  resource_group_name          = azurerm_resource_group.example.name
  revision_mode                = "Single"


  ingress {
    target_port = 80
    #transport                  = "auto"
    allow_insecure_connections = true
    external_enabled           = true
    //fqdn             = "backend"
    traffic_weight {
      percentage = 100
      # revision_suffix = "revision-suffix-example-be-11234"
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
    value = data.azurerm_key_vault_secret.my_first_app_secret.value
  }

  template {
    container {
      name   = "examplecontainerapp-be-private"
      image  = "ghcr.io/andrejvysny/nginx-hello-world-private:latest"
      cpu    = 0.25
      memory = "0.5Gi"

    }
  }

  tags = {
    paid    = true
    purpose = "testing"
  }
}

*/
