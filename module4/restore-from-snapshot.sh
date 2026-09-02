#!/bin/bash
set -e

echo "=== Module 4: Cinder Snapshot and Restore ==="
VOLUME_NAME="module4-data-volume"
SNAPSHOT_NAME="module4-data-snapshot"
RESTORED_VOLUME_NAME="module4-restored-volume"
RECOVERY_SERVER="module4-recovery-server"
IMAGE_NAME="Fedora-Cloud-Base-37-1.7.x86_64" # Using Fedora
FLAVOR_NAME="m1.small"
KEY_NAME="module3-key-pair"
RECOVERY_NET="module2-dmz-net"
ORIGINAL_SERVER="module3-web-server"

# NOTE: Before running this script, ensure you have run 'sync' and 'sudo umount /mnt/data' inside VM1!

echo "-> Detaching original volume from VM1 ($ORIGINAL_SERVER)..."
openstack server remove volume $ORIGINAL_SERVER $VOLUME_NAME

echo "-> Waiting for volume to become available after detach..."
while [ "$(openstack volume show -f value -c status $VOLUME_NAME)" != "available" ]; do
    sleep 2
done

echo "-> Creating snapshot ($SNAPSHOT_NAME) from volume ($VOLUME_NAME)..."
openstack volume snapshot create --volume $VOLUME_NAME $SNAPSHOT_NAME

echo "-> Waiting for snapshot to complete..."
while [ "$(openstack volume snapshot show -f value -c status $SNAPSHOT_NAME)" != "available" ]; do
    sleep 2
done

echo "-> Creating new volume ($RESTORED_VOLUME_NAME) from snapshot..."
openstack volume create --snapshot $SNAPSHOT_NAME --size 1 $RESTORED_VOLUME_NAME

echo "-> Waiting for restored volume to become available..."
while [ "$(openstack volume show -f value -c status $RESTORED_VOLUME_NAME)" != "available" ]; do
    sleep 2
done

echo "-> Creating recovery server ($RECOVERY_SERVER)..."
openstack server create $RECOVERY_SERVER \
  --image $IMAGE_NAME \
  --flavor $FLAVOR_NAME \
  --key-name $KEY_NAME \
  --config-drive true \
  --network $RECOVERY_NET

echo "-> Waiting for server to become ACTIVE..."
while [ "$(openstack server show -f value -c status $RECOVERY_SERVER)" != "ACTIVE" ]; do
    sleep 3
done

echo "-> Attaching restored volume to recovery server..."
openstack server add volume $RECOVERY_SERVER $RESTORED_VOLUME_NAME

echo "=== Snapshot and Restore Completed ==="
openstack server show $RECOVERY_SERVER
echo "NOTE: Assign a Floating IP to $RECOVERY_SERVER to SSH into it and verify data persistence."
