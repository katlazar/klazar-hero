#!/bin/bash

azLogin=k.lazar@dtpoland.com
groupName=klazar_rg
imName=hero-go
registryName=acad4heroes
containerName=golangcont
acrName=acad4heroes.azurecr.io
imageName=acad4heroes.azurecr.io/katlaz-goapi:v3
subscriptionID="eec1a2bf-a168-499a-a5ed-d8c392ad1329"
line="==============================================="

echo $line
echo "  AZURE LOGIN"
echo $line
echo read -p "Please enter Azure password: " -s azPassword
echo az login -u $azLogin -p $azPassword
echo az account set --subscription $subscriptionID
echo az account show
echo

echo $line
echo "  DOCKER IMAGE BUILDING"
echo $line
docker build -t $imageName -f Dockerfile-go .
echo

echo $line
echo "  AZURE GROUP CREATING"
echo $line
az login
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
docker push $imageName
docker push $imName
echo

echo $line
echo "  RUNNING NEW CONTAINER FROM CONTAINER REGISTRY"
echo $line
username=`az acr credential show -n $registryName --query username` 
username="${username:1:${#username}-2}"
password=`az acr credential show -n $registryName --query passwords[0].value` 
password="${password:1:${#password}-2}"
az container create -g $groupName --name $containerName --image $imageName --ports 8080 -l westeurope --restart-policy OnFailure --dns-name-label $containerName --registry-username $username --registry-password $password
echo

echo $line
echo -e "  THE END\a"
echo $line
echo