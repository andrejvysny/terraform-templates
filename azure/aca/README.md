# Azure Container Apps Template - Work In Progress


## Setup Environment 

```bash
terraform init
```

```bash
terraform apply
```



## Update container with new image

```bash 
bash update.sh <Container-App-Name> <Image>
```

Full command:

```bash
az containerapp update --name <Container-App-Name> --resource-group <Resource-Group-Name> --image <Image-Url>:<Tag>
```


## Docs:
https://learn.microsoft.com/en-us/cli/azure/containerapp?view=azure-cli-latest

https://learn.microsoft.com/en-us/azure/container-apps/containers#sidecar-containers

https://medium.com/@vivazmo/azure-container-apps-container-with-terraform-azure-key-vault-for-secrets-part-2-f888d9d682de
