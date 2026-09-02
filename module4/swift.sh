#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Module 4: Swift Setup ==="
CONTAINER_NAME="module4-tetris-src"

echo "-> Creating Swift container ($CONTAINER_NAME)..."
openstack container create $CONTAINER_NAME
openstack container set --property 'Read-ACL=.r:*' $CONTAINER_NAME

echo "-> Uploading application source to Swift..."
openstack object create $CONTAINER_NAME "$SCRIPT_DIR/app-src/index.html" --name index.html

echo "=== Swift Setup Completed ==="
openstack object list $CONTAINER_NAME
