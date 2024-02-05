terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.31.1"
    }
  }
}


provider "azurerm" {
  features {

  }
}


################ VARIABLES ##################

variable "location" {
  default = "westeurope" # must be as URL string
}

variable "dns_name" {
  default = "multi-container-example" # must be as URL string - subdomain name - must be unique in location
}

################ VARIABLES ##################



resource "azurerm_resource_group" "rg" {

  name     = "example-resource-group-with-terraform"
  location = var.location
  tags = {
    example = "tag" # Tag your resource group like: environment=dev ... 
  }
}


resource "azurerm_container_group" "example_aci" {
  name                = "example_aci"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_address_type     = "Public" # Public to be accesible from Internet
  dns_name_label      = var.dns_name
  os_type             = "Linux"


  container {
    name   = "example-backend"
    image  = "ghcr.io/andrejvysny/complex-be:latest"
    cpu    = "0.5"
    memory = "1"

    environment_variables = {
      # ...  Your ENV variables for container
    }

    ports {
      port     = 8080 # Port on which is application in container running
      protocol = "TCP"
    }
  }

  container {
    name   = "example-frontend"
    image  = "ghcr.io/andrejvysny/complex-fe:latest"
    cpu    = "0.5"
    memory = "1"

    environment_variables = {
      # ...  Your ENV variables for container
      BACKEND_HOST = "http://${var.dns_name}.${var.location}.azurecontainer.io:8080"
      TEST_ENV     = "Example ENV variable"
    }

    ports {
      port     = 80 # Port on which is application in container running
      protocol = "TCP"
    }
  }

  # In case you are using private images from external registry such as Github Container Registry
  #image_registry_credential { 
  # server   = "ghcr.io"
  # username = "your_user_name"
  # password = "your_access_token" # Should use Vault to reterive the password
  #}

  tags = {
    environment = "dev"
  }
}



output "container_group_fqdn" {
  value = azurerm_container_group.example_aci.fqdn # Display URL of running container in console
}

output "container_group_ip_address" {
  value = azurerm_container_group.example_aci.ip_address # Display IP address of running container in console
}