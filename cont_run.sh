#!/bin/bash

groupName=klazar_rg
registryName=acad4heroes
containerName=golangcont
imageName=acad4heroes.azurecr.io/katlaz-goapi:v3
line="==============================================="


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