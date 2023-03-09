#!/bin/bash

app_name="webapp"

echo
echo "=Build and Run Docker Image:"
docker build -t ${app_name} .
echo

echo "=Create named Docker Volume"
docker volume create --name vol-${app_name}
echo

echo "=Run Docker Container from Image "
docker run --rm -d -p 80:5000 \
--name ${app_name} \
-v vol-webapp:/opt/app ${app_name}
echo

echo "=Check is Docker Image, Container and Volume is exists "
docker images && echo && docker ps -a && echo && docker volume ls
echo

echo "=Docker volumes root directory content:"
sudo -i ls /var/lib/docker/volumes
echo

echo "=Docker app volume directory content:"
sudo -i ls /var/lib/docker/volumes/vol-${app_name}/_data
echo
