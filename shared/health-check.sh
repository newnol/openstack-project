#!/usr/bin/env bash
set -euo pipefail

DEVSTACK_DIR=${DEVSTACK_DIR:-$HOME/devstack}
OPENSTACK_USER=${OPENSTACK_USER:-demo}
OPENSTACK_PROJECT=${OPENSTACK_PROJECT:-demo}

source "$DEVSTACK_DIR/openrc" "$OPENSTACK_USER" "$OPENSTACK_PROJECT"

echo '== Token =='
openstack token issue

echo '== Compute services =='
openstack compute service list

echo '== Hypervisors =='
openstack hypervisor list

echo '== Network agents =='
openstack network agent list

echo '== Images =='
openstack image list

echo '== Networks =='
openstack network list

echo '== Servers =='
openstack server list

echo '== Swift =='
openstack container list

# The demo role may not be authorized to list Heat engines, so use stack list
# as the project-level Heat API health check.
echo '== Heat =='
openstack stack list

echo 'OPENSTACK_HEALTH_CHECK_PASS'
