# Module 2 — Tenant Network Topology

Owner: Network / Compute Lead

## Goal

Create isolated DMZ and private networks, connect both to one router with an external `public` gateway, add security groups, and verify connectivity.

## Required resources

Use these names unless the team agrees otherwise:

```text
m2-dmz-net
m2-dmz-subnet
m2-private-net
m2-private-subnet
m2-router
m2-web-sg
```

Choose non-overlapping CIDRs and document them before creation.

## Deliverables

- `create-topology.sh`
- `cleanup-topology.sh` with explicit resource names and confirmation
- `topology.md`
- `evidence/` containing Horizon and CLI screenshots/logs
- `../report/diagrams/module2_diagram.png`

## Verification checklist

```bash
openstack network list
openstack subnet list
openstack router show m2-router
openstack port list
openstack security group rule list m2-web-sg
```

Capture visibility of networks, subnets, router ports/interfaces and security-group rules in Horizon.

Do not delete or rename DevStack's default `private`, `public`, `shared`, `heat-net`, or `router1` resources.
