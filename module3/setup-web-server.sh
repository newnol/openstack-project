#!/bin/bash
# Usage: source openrc admin admin (or the appropriate user) then run ./setup-web-server.sh

set -e

echo "=== Starting Module 3: Web Server Setup ==="

# 1. Define variables
SG_NAME="module3-web-sg"
KEY_NAME="module3-key-pair"

DMZ_NET="module2-dmz-net"
DMZ_PORT="module3-web-dmz-port"

PRIVATE_NET="module2-private-net"
PRIVATE_PORT="module3-web-private-port"

SERVER_NAME="module3-web-server"
IMAGE_NAME="Ubuntu"
FLAVOR_NAME="m1.small"
EXTERNAL_NET="public"

# 2. Create Security Group (if not already exists)
if ! openstack security group show $SG_NAME >/dev/null 2>&1; then
    echo "-> Creating Security Group ($SG_NAME)..."
    openstack security group create $SG_NAME --description "Allow SSH and HTTP"
    echo "-> Allowing Port 22 (SSH)..."
    openstack security group rule create --protocol tcp --dst-port 22 --remote-ip 0.0.0.0/0 $SG_NAME
    echo "-> Allowing Port 80 (HTTP)..."
    openstack security group rule create --protocol tcp --dst-port 80 --remote-ip 0.0.0.0/0 $SG_NAME
    echo "-> Allowing ICMP (Ping) for debugging..."
    openstack security group rule create --protocol icmp $SG_NAME
fi

# 3. Create Keypair
# Skip this step if you already have a keypair. Note: This command creates m3-web-key.pem on the lab server
if ! openstack keypair show $KEY_NAME >/dev/null 2>&1; then
    echo "-> Creating Keypair ($KEY_NAME)..."
    openstack keypair create $KEY_NAME > $KEY_NAME.pem
    chmod 600 $KEY_NAME.pem
fi

# 4. Create separate network ports (if not already exist)
if ! openstack port show $DMZ_PORT >/dev/null 2>&1; then
    echo "-> Creating Port for DMZ..."
    openstack port create --network $DMZ_NET --security-group $SG_NAME $DMZ_PORT
fi

if ! openstack port show $PRIVATE_PORT >/dev/null 2>&1; then
    echo "-> Creating Port for Private..."
    openstack port create --network $PRIVATE_NET --security-group $SG_NAME $PRIVATE_PORT
fi

# 5. Prepare User-Data to resolve Dual-NIC routing on boot
USER_DATA_FILE="/tmp/m3_user_data.sh"
cat << 'EOF' > "$USER_DATA_FILE"
#!/bin/bash
sleep 3
DMZ_IFACE=$(ip -o -4 addr show to 10.10.10.0/24 | awk '{print $2}' | head -n1)
if [ -n "$DMZ_IFACE" ]; then
    ip route replace default via 10.10.10.1 dev "$DMZ_IFACE" metric 50
fi
EOF

# 6. Launch the virtual machine (VM)
echo "-> Launching VM ($SERVER_NAME) with dual NICs..."
openstack server create $SERVER_NAME \
  --image $IMAGE_NAME \
  --flavor $FLAVOR_NAME \
  --key-name $KEY_NAME \
  --config-drive true \
  --user-data "$USER_DATA_FILE" \
  --port $DMZ_PORT \
  --port $PRIVATE_PORT

# 7. Allocate and associate Floating IP (reuse if already assigned)
FIP=$(openstack floating ip list --port $DMZ_PORT -f value -c "Floating IP Address")
if [ -z "$FIP" ]; then
    echo "-> Allocating a Floating IP from $EXTERNAL_NET network..."
    FIP=$(openstack floating ip create $EXTERNAL_NET -f value -c floating_ip_address)
    echo "-> Associating Floating IP ($FIP) to the DMZ port..."
    openstack floating ip set --port $DMZ_PORT $FIP
else
    echo "-> Reusing existing Floating IP ($FIP) on DMZ port..."
fi

echo "=== Module 3 Basic Configuration Completed ==="
echo "The Web Server Floating IP is: $FIP"
echo "You can SSH into it using: ssh -i $KEY_NAME.pem ubuntu@$FIP"
