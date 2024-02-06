terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.90.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}




resource "azurerm_resource_group" "example" {
  name     = "aca-example-resources-complex"
  location = "West Europe"
}
/*
resource "azurerm_log_analytics_workspace" "example" {
  name                = "acctest-01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
*/
resource "azurerm_container_app_environment" "example" {
  name                       = "Example-Environment"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  log_analytics_workspace_id = null
}


resource "azurerm_container_app" "example" {
  name                         = "example-app"
  container_app_environment_id = azurerm_container_app_environment.example.id
  resource_group_name          = azurerm_resource_group.example.name
  revision_mode                = "Single"


  ingress {
    target_port = 80
    #exposed_port = 80
    #transport                  = "auto"
    #allow_insecure_connections = true
    external_enabled = true
    traffic_weight {
      percentage = 100
      #revision_suffix = "revision-suffix-example-11234"
      latest_revision = true

    }



  }

  template {
    container {
      name   = "examplecontainerapp"
      image  = "ghcr.io/andrejvysny/complex-fe:latest"
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name  = "BACKEND_HOST"
        value = azurerm_container_app.example-be.ingress[0].fqdn
      }
      env {
        name  = "PRIVATE_BACKEND_HOST"
        value = azurerm_container_app.example-be-private.ingress[0].fqdn

      }
      env {
        name  = "TEST_ENV"
        value = "example value"

      }
    }
  }

  tags = {
    paid    = true
    purpose = "testing"
  }
}



//https://learn.microsoft.com/en-us/azure/container-apps/containers#sidecar-containers
//https://medium.com/@vivazmo/azure-container-apps-container-with-terraform-azure-key-vault-for-secrets-part-2-f888d9d682de


resource "azurerm_container_app" "example-be" {
  name                         = "example-be"
  container_app_environment_id = azurerm_container_app_environment.example.id
  resource_group_name          = azurerm_resource_group.example.name
  revision_mode                = "Single"


  ingress {
    target_port = 8080
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

  template {
    container {
      name   = "examplecontainerapp-be"
      image  = "ghcr.io/andrejvysny/complex-be:latest"
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name  = "MESSAGE"
        value = "Hello from Publix terraform ENV message"
      }
    }
  }

  tags = {
    paid    = true
    purpose = "testing"
  }
}



resource "azurerm_container_app" "example-be-private" {
  name                         = "example-be-private"
  container_app_environment_id = azurerm_container_app_environment.example.id
  resource_group_name          = azurerm_resource_group.example.name
  revision_mode                = "Single"


  ingress {
    target_port = 8080
    #transport                  = "auto"
    allow_insecure_connections = true
    external_enabled           = false
    //fqdn             = "backend"
    traffic_weight {
      percentage = 100
      # revision_suffix = "revision-suffix-example-be-11234"
      latest_revision = true

    }
  }

  template {
    container {
      name   = "examplecontainerapp-be-private"
      image  = "ghcr.io/andrejvysny/complex-be:latest"
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name  = "MESSAGE"
        value = "Hello from PRIVATE terraform ENV message"
      }
    }
  }

  tags = {
    paid    = true
    purpose = "testing"
  }
}




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

output "azurerm_container_app_url" {
  value = azurerm_container_app.example.ingress[0].fqdn
}

output "azurerm_container_app_url_be_private" {
  value = azurerm_container_app.example-be-private.ingress[0].fqdn
}

output "azurerm_container_app_url_example_private" {
  value = azurerm_container_app.example-private.ingress[0].fqdn
}