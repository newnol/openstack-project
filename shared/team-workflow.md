# Team workflow

## Ownership

| Role | Scope |
|---|---|
| Infra / Integration Lead | DevStack, host health, Module 1, snapshots, repository, report merge |
| Network / Compute Lead | Modules 2–3, Neutron topology, dual-NIC VM, floating IP, HTTP |
| Storage / Automation Lead | Modules 4–5, Swift, Cinder, snapshot recovery, Heat, cloud-init |

## Dependency chain

```text
Base platform → Module 1 → Module 2 → Module 3 → Module 4 integration → Module 5 integration
```

Storage and Heat scripts may be prepared while Module 2–3 are in progress, but Module 4 cannot be considered integrated until its VM can reach Swift.

## Shared-lab rules

1. Never rerun `stack.sh`, `unstack.sh`, or `clean.sh`.
2. Only the Infra Lead changes platform service configuration or reboots the host.
3. Prefix every resource with its module number.
4. Do not bulk-delete resources.
5. Save command output and screenshots immediately.
6. Use branches and pull requests; do not push directly to `main` after team onboarding.
7. Keep credentials out of GitHub and exchange them privately.

## Handoffs

### Module 1 → Module 2

Verify Nova, hypervisor, OVN agents, images, Heat and Swift. Record the existing default networks and avoid changing or deleting them unless the plan explicitly requires it.

### Module 2 → Module 3

Record network names, subnet CIDRs, router interfaces, external gateway, security group IDs, ports and routes.

### Module 3 → Module 4

Record the server, DMZ/private ports, floating IP, guest routing table and Swift endpoint reachability.

### Module 4 → Module 5

Record the Swift container/object, Cinder volume/snapshot/restored volume and the exact application bootstrap procedure. Module 5 should use an independent `m5-*` namespace.
