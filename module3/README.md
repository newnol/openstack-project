# Module 3 — Dual-NIC Web Service

Owner: Network / Compute Lead

## Goal

Launch a web-server VM with one NIC on the Module 2 DMZ network and one NIC on its private network, associate a floating IP specifically with the DMZ port, allow SSH/HTTP, and verify the HTTP response externally.

## Resource names

```text
m3-web-server
m3-web-port-dmz
m3-web-port-private
m3-floating-ip
```

Reuse `m2-web-sg` only if its rules are documented and correct.

## Critical routing requirement

A dual-homed guest can suffer asymmetric routing. Capture:

```bash
ip addr
ip route
```

Only the DMZ-facing interface should hold the default route. Add explicit routes for the private side instead of creating a second default route.

## Deliverables

- `create-service.sh`
- `configure-routing.sh`
- application source or bootstrap script
- `evidence/instance-show.txt`
- `evidence/port-list.txt`
- `evidence/ip-route.txt`
- `evidence/web-test.png`

## Verification

```bash
openstack server show m3-web-server
openstack port list --server m3-web-server
openstack floating ip list
curl -v http://<floating-ip>/
```
