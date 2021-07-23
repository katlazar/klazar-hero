#!/bin/bash

imageName=heroes/katlaz-netapi:v1
line="==============================================="

echo $line
echo "  DOCKER IMAGE BUILDING"
echo $line
docker build -t $imageName -f Dockerfile .
echo

echo $line
echo -e "  THE END\a"
echo $line
echo