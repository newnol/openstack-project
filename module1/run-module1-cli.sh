#!/usr/bin/env bash
set -eo pipefail

DEVSTACK_DIR=${DEVSTACK_DIR:-$HOME/devstack}
[[ -d "$DEVSTACK_DIR" ]] || DEVSTACK_DIR="/opt/stack/devstack"
EVIDENCE_DIR=${EVIDENCE_DIR:-$HOME/openstack-project/module1/cli}
SERVER_NAME=${SERVER_NAME:-module1-cli-instance}
mkdir -p "$EVIDENCE_DIR"
exec > >(tee "$EVIDENCE_DIR/module1-cli.log") 2>&1

source "$DEVSTACK_DIR/openrc" admin admin

run() {
  printf '\n$ %q' "$1"
  shift
  printf ' %q' "$@"
  printf '\n'
  "$@"
}

printf 'Module 1 CLI evidence generated at %s\n' "$(date --iso-8601=seconds)"
run openstack openstack token issue
run openstack-service-list openstack service list
run openstack-endpoint-list openstack endpoint list
run compute-service-list openstack compute service list
run hypervisor-list openstack hypervisor list
run image-list openstack image list
run flavor-list openstack flavor list
run keypair-list openstack keypair list
run security-group-list openstack security group list
run network-list openstack network list
run subnet-list openstack subnet list
run router-list openstack router list
run orchestration-service-list openstack orchestration service list
run stack-list openstack stack list
run swift-container-list openstack container list

IMAGE=$(openstack image list --status active -f value -c Name | grep -m1 '^cirros-' || true)
NETWORK=$(openstack network list --internal -f value -c Name | grep -m1 '^private$' || true)
FLAVOR=$(openstack flavor list -f value -c Name | grep -m1 '^m1.nano$' || true)

# Fall back to any suitable object only when the standard DevStack defaults
# are absent. Sort images by minimum disk so a large Fedora image is not
# accidentally paired with a 1 GiB lab flavor.
[[ -n "$IMAGE" ]] || IMAGE=$(openstack image list --status active -f value -c Name | head -n1)
[[ -n "$NETWORK" ]] || NETWORK=$(openstack network list --internal -f value -c Name | head -n1)
[[ -n "$FLAVOR" ]] || FLAVOR=$(openstack flavor list -f value -c Name | head -n1)

if [[ -z "$IMAGE" || -z "$NETWORK" || -z "$FLAVOR" ]]; then
  echo 'Cannot launch Module 1 instance: image, internal network, or flavor is missing.' >&2
  exit 1
fi

openstack server delete --wait "$SERVER_NAME" 2>/dev/null || true
run server-create openstack server create \
  --image "$IMAGE" \
  --flavor "$FLAVOR" \
  --network "$NETWORK" \
  --wait "$SERVER_NAME"
run server-show openstack server show "$SERVER_NAME"
run server-list-openstack openstack server list
run server-delete openstack server delete --wait "$SERVER_NAME"
run server-list-after-delete openstack server list

printf '\nModule 1 CLI lifecycle completed successfully at %s\n' "$(date --iso-8601=seconds)"
