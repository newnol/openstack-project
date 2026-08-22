#!/bin/bash
set -e

STACK_NAME="module5-stack"
TEMPLATE_FILE="module5/service.yaml"

echo "=== 1. Validating Heat Template ==="
openstack orchestration template validate -t $TEMPLATE_FILE

echo -e "\n=== 2. Creating Heat Stack ($STACK_NAME) ==="
openstack stack create -t $TEMPLATE_FILE $STACK_NAME

echo -e "\n=== 3. Waiting for Stack to Complete ==="
echo "You can monitor the status using: openstack stack event list $STACK_NAME"
while [ "$(openstack stack show -f value -c stack_status $STACK_NAME)" != "CREATE_COMPLETE" ]; do
    status=$(openstack stack show -f value -c stack_status $STACK_NAME)
    if [ "$status" == "CREATE_FAILED" ]; then
        echo "Stack creation failed! Check events:"
        openstack stack event list $STACK_NAME
        exit 1
    fi
    echo "Current status: $status... waiting 10s"
    sleep 10
done

echo -e "\n=== 4. Stack Resources ==="
openstack stack resource list $STACK_NAME

echo -e "\n=== 5. Stack Outputs ==="
openstack stack output show $STACK_NAME --all

echo -e "\n=== 6. Service URL ==="
FIP=$(openstack stack output show $STACK_NAME floating_ip -f value -c output_value)
echo "Web Service is running at: http://$FIP"
echo "You can test it with: curl http://$FIP"
