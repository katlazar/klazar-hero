#!/bin/bash
azLogin=k.lazar@dtpoland.com
groupName=klazar_rg
registryName=acad4heroes
imageName=acad4heroes.azurecr.io/katlaz-goapi:v5
line="==============================================="

echo $line
echo "  AZURE LOGIN"
echo $line
az login -u $azLogin
echo

echo $line
echo "  DOCKER IMAGE BUILDING"
echo $line
echo docker build -t $imageName -f Dockerfile-go .
echo

echo $line
echo "  AZURE GROUP CREATING"
echo $line
az group create --name $groupName --location westeurope  
echo

echo $line
echo "  NEW CONTAINER REGISTRY CREATING"
echo $line
az acr create --resource-group $groupName --name $registryName --sku Basic --location westeurope  --admin-enabled true 
az acr login --name $registryName
echo

echo $line
echo "  PUSHING IMAGE TO CONTAINER REGISTRY"
echo $line
echo docker push $imageName
echo

echo $line
echo -e "  THE END\a"
echo $line
echo