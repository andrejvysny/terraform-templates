# Azure Container Instances

### Simple one-file templates to deploy containers on Azure Container Instances (ACI)


More info on: 

https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_group


### Intall Terraform and Azure CLI

1. https://developer.hashicorp.com/terraform/install

2. https://learn.microsoft.com/en-us/cli/azure/install-azure-cli

### Getting Started

1. Copy your template file to `main.tf`

2. Make changes 
 - change image 
 - add registry credentials 
 - ...

3. Run: 

```bash
terraform init
```

```bash
terraform plan 
```

```bash
terraform apply 
```