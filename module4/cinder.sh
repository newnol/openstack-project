#!/bin/bash
set -e

echo "=== Module 4: Cinder Volume Setup ==="
VOLUME_NAME="module4-data-volume"
SERVER_NAME="module3-web-server"

echo "-> Creating Cinder volume ($VOLUME_NAME)..."
openstack volume create --size 1 $VOLUME_NAME

echo "-> Waiting for volume to become available..."
while [ "$(openstack volume show -f value -c status $VOLUME_NAME)" != "available" ]; do
    sleep 2
done

echo "-> Attaching volume to server ($SERVER_NAME)..."
openstack server add volume $SERVER_NAME $VOLUME_NAME

echo "=== Cinder Volume Setup Completed ==="
openstack volume list
