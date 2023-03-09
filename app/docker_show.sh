#!/bin/bash

app_name="webapp"

echo
echo "=Check Docker Images, Containers and Volumes:"
docker images && echo && docker ps -a && echo && docker volume ls
echo

echo "=Docker volumes root directory content:"
sudo -i ls /var/lib/docker/volumes
echo

echo "=Docker app volume directory content:"
sudo -i ls /var/lib/docker/volumes/vol-${app_name}/_data
echo
