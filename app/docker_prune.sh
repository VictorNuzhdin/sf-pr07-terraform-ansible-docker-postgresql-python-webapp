#!/bin/bash

app_name="webapp"

echo
echo "=Stop and remove Docker Container, remove Volume, remove Image:"
docker stop ${app_name}
#docker container rm ${app_name}
docker volume rm vol-${app_name}
docker image rm ${app_name}
echo

echo "=Check is all cleared:"
docker images && echo && docker ps -a && echo && docker volume ls
echo

echo "=Docker volumes root directory content:"
#sudo -i ls /var/lib/docker/volumes/vol-${app_name}/_data
sudo -i ls /var/lib/docker/volumes
echo
