#!/bin/bash
set -e

echo "=== Module 4: Swift Setup ==="
CONTAINER_NAME="module4-tetris-src"

echo "-> Creating Swift container ($CONTAINER_NAME)..."
openstack container create $CONTAINER_NAME

echo "-> Uploading application source to Swift..."
openstack object create $CONTAINER_NAME app-src/index.html

echo "=== Swift Setup Completed ==="
openstack object list $CONTAINER_NAME
