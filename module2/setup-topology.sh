#!/bin/bash
# Usage: source openrc admin admin (or the appropriate user) then run ./setup-topology.sh

# Exit immediately if a command exits with a non-zero status
set -e

echo "=== Starting Module 2: Network Topology Setup ==="

# 1. Define environment variables
EXTERNAL_NET="public" # Name of the existing public network in DevStack

DMZ_NET="m2-dmz-net"
DMZ_SUBNET="m2-dmz-subnet"
DMZ_CIDR="10.10.10.0/24"
DMZ_GW="10.10.10.1"

PRIVATE_NET="m2-private-net"
PRIVATE_SUBNET="m2-private-subnet"
PRIVATE_CIDR="10.10.20.0/24"
PRIVATE_GW="10.10.20.1"

ROUTER_NAME="m2-router"

# 2. Create DMZ Network & Subnet
echo "-> Creating DMZ Network ($DMZ_NET)..."
openstack network create $DMZ_NET

echo "-> Creating DMZ Subnet ($DMZ_SUBNET) with CIDR $DMZ_CIDR..."
openstack subnet create $DMZ_SUBNET \
  --network $DMZ_NET \
  --subnet-range $DMZ_CIDR \
  --gateway $DMZ_GW \
  --dns-nameserver 8.8.8.8

# 3. Create Private Network & Subnet
echo "-> Creating Private Network ($PRIVATE_NET)..."
openstack network create $PRIVATE_NET

echo "-> Creating Private Subnet ($PRIVATE_SUBNET) with CIDR $PRIVATE_CIDR..."
openstack subnet create $PRIVATE_SUBNET \
  --network $PRIVATE_NET \
  --subnet-range $PRIVATE_CIDR \
  --gateway $PRIVATE_GW \
  --dns-nameserver 8.8.8.8

# 4. Create Router
echo "-> Creating Router ($ROUTER_NAME)..."
openstack router create $ROUTER_NAME

# 5. Set external gateway for Router
echo "-> Setting External Gateway ($EXTERNAL_NET) for Router..."
openstack router set $ROUTER_NAME --external-gateway $EXTERNAL_NET

# 6. Attach subnets to Router
echo "-> Attaching DMZ Subnet to Router..."
openstack router add subnet $ROUTER_NAME $DMZ_SUBNET

echo "-> Attaching Private Subnet to Router..."
openstack router add subnet $ROUTER_NAME $PRIVATE_SUBNET

echo "=== Module 2 Setup Completed ==="
echo "You can verify the topology in Horizon -> Project -> Network -> Network Topology."
