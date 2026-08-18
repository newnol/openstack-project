# Module 1 — Horizon and Core Services

Status: functionally complete.

## Requirements covered

- Login through Horizon as `demo`
- Compute: Overview, Instances, Images, Key Pairs, Security Groups
- Network: Networks, Subnets, Routers
- Orchestration: Heat Stacks
- Object Store: Swift Containers
- Instance launch/delete through CLI
- Instance launch through Horizon UI

## Evidence

| File | Evidence |
|---|---|
| `evidence/horizon/00-horizon-launch-dialog.png` | Horizon launch dialog |
| `evidence/horizon/01-compute-overview.png` | Compute overview and usage |
| `evidence/horizon/02-compute-instances-active.png` | Horizon instance Active/Running |
| `evidence/horizon/03-compute-images.png` | Active CirrOS/Fedora images |
| `evidence/horizon/04-compute-key-pairs.png` | Key Pairs dashboard |
| `evidence/horizon/05-network-security-groups.png` | Security Groups dashboard |
| `evidence/horizon/06-network-networks.png` | Networks dashboard |
| `evidence/horizon/06b-network-subnets.png` | `private` IPv4/IPv6 subnets |
| `evidence/horizon/07-network-routers.png` | Active router and public gateway |
| `evidence/horizon/08-orchestration-stacks.png` | Heat Stacks dashboard |
| `evidence/horizon/09-object-store-containers.png` | Swift Containers dashboard |
| `evidence/horizon/10-compute-instances-after-terminate.png` | Empty instance list after a verified termination |
| `evidence/cli/module1-cli.log` | Full CLI inventory and instance lifecycle |

## Reproduce the CLI lifecycle

On the OpenStack host:

```bash
chmod +x ~/run-module1-cli.sh
~/run-module1-cli.sh
```

From this repository:

```bash
scp module1/run-module1-cli.sh newnol@192.168.2.10:~/run-module1-cli.sh
ssh newnol@192.168.2.10 'chmod +x ~/run-module1-cli.sh && ~/run-module1-cli.sh'
```

The script creates `module1-cli-instance`, waits for `ACTIVE`, records its details, then deletes it.

## Final cleanup note

A new `module1-horizon-instance` was launched directly through Horizon UI to strengthen the evidence. It is intentionally not deleted by repository automation because deletion is destructive. Before Module 2 begins, the Infra Lead should delete it through Horizon and optionally refresh `10-compute-instances-after-terminate.png`.
