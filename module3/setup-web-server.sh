#!/bin/bash
# Usage: source openrc admin admin (or the appropriate user) then run ./setup-web-server.sh

set -e

echo "=== Starting Module 3: Web Server Setup ==="

# 1. Define variables
SG_NAME="m3-web-sg"
KEY_NAME="m3-web-key"

DMZ_NET="m2-dmz-net"
DMZ_PORT="m3-web-dmz-port"

PRIVATE_NET="m2-private-net"
PRIVATE_PORT="m3-web-private-port"

SERVER_NAME="m3-web-server"
IMAGE_NAME="Ubuntu" # Can be changed to cirros if required by the lab
FLAVOR_NAME="m1.small"
EXTERNAL_NET="public"

# 2. Create Security Group
echo "-> Creating Security Group ($SG_NAME)..."
openstack security group create $SG_NAME --description "Allow SSH and HTTP"

echo "-> Allowing Port 22 (SSH)..."
openstack security group rule create --protocol tcp --dst-port 22 --remote-ip 0.0.0.0/0 $SG_NAME

echo "-> Allowing Port 80 (HTTP)..."
openstack security group rule create --protocol tcp --dst-port 80 --remote-ip 0.0.0.0/0 $SG_NAME

echo "-> Allowing ICMP (Ping) for debugging..."
openstack security group rule create --protocol icmp $SG_NAME

# 3. Create Keypair
# Skip this step if you already have a keypair. Note: This command creates m3-web-key.pem on the lab server
if ! openstack keypair show $KEY_NAME >/dev/null 2>&1; then
    echo "-> Creating Keypair ($KEY_NAME)..."
    openstack keypair create $KEY_NAME > $KEY_NAME.pem
    chmod 600 $KEY_NAME.pem
fi

# 4. Create separate network ports
echo "-> Creating Port for DMZ..."
openstack port create --network $DMZ_NET --security-group $SG_NAME $DMZ_PORT

echo "-> Creating Port for Private..."
openstack port create --network $PRIVATE_NET --security-group $SG_NAME $PRIVATE_PORT

# 5. Launch the virtual machine (VM)
echo "-> Launching VM ($SERVER_NAME) with dual NICs..."
openstack server create $SERVER_NAME \
  --image $IMAGE_NAME \
  --flavor $FLAVOR_NAME \
  --key-name $KEY_NAME \
  --port $DMZ_PORT \
  --port $PRIVATE_PORT

# 6. Allocate and associate Floating IP
echo "-> Allocating a Floating IP from $EXTERNAL_NET network..."
FIP=$(openstack floating ip create $EXTERNAL_NET -f value -c floating_ip_address)

echo "-> Associating Floating IP ($FIP) to the DMZ port..."
openstack floating ip set --port $DMZ_PORT $FIP

echo "=== Module 3 Basic Configuration Completed ==="
echo "The Web Server Floating IP is: $FIP"
echo "You can SSH into it using: ssh -i $KEY_NAME.pem ubuntu@$FIP"
