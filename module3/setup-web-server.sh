#!/bin/bash
# Hướng dẫn chạy: source openrc admin admin (hoặc user tương ứng) rồi chạy ./setup-web-server.sh

set -e

echo "=== Bắt đầu cài đặt Module 3: Web Server ==="

# 1. Định nghĩa biến
SG_NAME="m3-web-sg"
KEY_NAME="m3-web-key"

DMZ_NET="m2-dmz-net"
DMZ_PORT="m3-web-dmz-port"

PRIVATE_NET="m2-private-net"
PRIVATE_PORT="m3-web-private-port"

SERVER_NAME="m3-web-server"
IMAGE_NAME="Ubuntu" # Có thể thay đổi thành cirros nếu lab yêu cầu
FLAVOR_NAME="m1.small"
EXTERNAL_NET="public"

# 2. Tạo Security Group (Giống AWS Security Group)
echo "-> Tạo Security Group ($SG_NAME)..."
openstack security group create $SG_NAME --description "Allow SSH and HTTP"

echo "-> Mở port 22 (SSH)..."
openstack security group rule create --protocol tcp --dst-port 22 --remote-ip 0.0.0.0/0 $SG_NAME

echo "-> Mở port 80 (HTTP)..."
openstack security group rule create --protocol tcp --dst-port 80 --remote-ip 0.0.0.0/0 $SG_NAME

echo "-> Mở ping (ICMP) để dễ debug..."
openstack security group rule create --protocol icmp $SG_NAME

# 3. Tạo Keypair (Giống AWS Key Pair)
# Bỏ qua bước này nếu bạn đã có keypair. Lưu ý: Lệnh này sẽ tạo ra file m3-web-key.pem trên lab server
if ! openstack keypair show $KEY_NAME >/dev/null 2>&1; then
    echo "-> Tạo Keypair ($KEY_NAME)..."
    openstack keypair create $KEY_NAME > $KEY_NAME.pem
    chmod 600 $KEY_NAME.pem
fi

# 4. Tạo các cổng mạng (Ports) riêng biệt thay vì để Nova tự gán
# Giống AWS Elastic Network Interface (ENI)
echo "-> Tạo Port cho DMZ..."
openstack port create --network $DMZ_NET --security-group $SG_NAME $DMZ_PORT

echo "-> Tạo Port cho Private..."
openstack port create --network $PRIVATE_NET --security-group $SG_NAME $PRIVATE_PORT

# 5. Khởi tạo máy ảo (VM)
# Giống AWS EC2 Instance Launch
echo "-> Launch VM ($SERVER_NAME) với 2 card mạng..."
openstack server create $SERVER_NAME \
  --image $IMAGE_NAME \
  --flavor $FLAVOR_NAME \
  --key-name $KEY_NAME \
  --port $DMZ_PORT \
  --port $PRIVATE_PORT

# 6. Tạo và gắn Floating IP (Giống AWS Elastic IP)
echo "-> Cấp một Floating IP từ mạng $EXTERNAL_NET..."
FIP=$(openstack floating ip create $EXTERNAL_NET -f value -c floating_ip_address)

echo "-> Gắn Floating IP ($FIP) vào cổng DMZ..."
openstack floating ip set --port $DMZ_PORT $FIP

echo "=== Đã hoàn thành cấu hình cơ bản Module 3 ==="
echo "Floating IP của Web Server là: $FIP"
echo "Bạn hãy SSH vào bằng lệnh: ssh -i $KEY_NAME.pem ubuntu@$FIP"
