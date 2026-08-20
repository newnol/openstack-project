#!/bin/bash
# Hướng dẫn chạy: source openrc admin admin (hoặc user tương ứng) rồi chạy ./setup-topology.sh

# Exit immediately if a command exits with a non-zero status
set -e

echo "=== Bắt đầu cài đặt Module 2: Network Topology ==="

# 1. Định nghĩa các biến môi trường
EXTERNAL_NET="public" # Tên mạng public có sẵn trong DevStack. (AWS: Tương đương Internet Gateway)

DMZ_NET="m2-dmz-net"
DMZ_SUBNET="m2-dmz-subnet"
DMZ_CIDR="10.10.10.0/24"
DMZ_GW="10.10.10.1"

PRIVATE_NET="m2-private-net"
PRIVATE_SUBNET="m2-private-subnet"
PRIVATE_CIDR="10.10.20.0/24"
PRIVATE_GW="10.10.20.1"

ROUTER_NAME="m2-router"

# 2. Tạo DMZ Network & Subnet
# OpenStack Network giống như 1 VPC trống ở AWS (Layer 2).
# OpenStack Subnet giống như Subnet trong AWS (Layer 3, có dải IP, DHCP).
echo "-> Tạo DMZ Network ($DMZ_NET)..."
openstack network create $DMZ_NET

echo "-> Tạo DMZ Subnet ($DMZ_SUBNET) với CIDR $DMZ_CIDR..."
openstack subnet create $DMZ_SUBNET \
  --network $DMZ_NET \
  --subnet-range $DMZ_CIDR \
  --gateway $DMZ_GW \
  --dns-nameserver 8.8.8.8

# 3. Tạo Private Network & Subnet
echo "-> Tạo Private Network ($PRIVATE_NET)..."
openstack network create $PRIVATE_NET

echo "-> Tạo Private Subnet ($PRIVATE_SUBNET) với CIDR $PRIVATE_CIDR..."
openstack subnet create $PRIVATE_SUBNET \
  --network $PRIVATE_NET \
  --subnet-range $PRIVATE_CIDR \
  --gateway $PRIVATE_GW \
  --dns-nameserver 8.8.8.8

# 4. Tạo Router
# OpenStack Router hoạt động giống như việc gắn Route Table kết nối tới Internet Gateway (IGW) ở AWS
echo "-> Tạo Router ($ROUTER_NAME)..."
openstack router create $ROUTER_NAME

# 5. Thiết lập external gateway cho Router (Gắn IGW vào Router)
echo "-> Gắn External Gateway ($EXTERNAL_NET) cho Router..."
openstack router set $ROUTER_NAME --external-gateway $EXTERNAL_NET

# 6. Gắn các subnet vào Router
# Gắn subnet vào router giống như thêm rule vào Route Table ở AWS cho phép subnet đi ra ngoài
echo "-> Gắn DMZ Subnet vào Router..."
openstack router add subnet $ROUTER_NAME $DMZ_SUBNET

echo "-> Gắn Private Subnet vào Router..."
openstack router add subnet $ROUTER_NAME $PRIVATE_SUBNET

echo "=== Đã hoàn thành Module 2 ==="
echo "Bạn có thể vào Horizon -> Project -> Network -> Network Topology để kiểm tra."
