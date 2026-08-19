# OpenStack Project — Modules 1–5

Shared repository for the three-person OpenStack course project. The lab runs on a single-node DevStack deployment, and this repository stores reproducible scripts, documentation, diagrams, templates, command logs, and screenshots.

## Current status

| Area | Status | Owner |
|---|---|---|
| Base infrastructure | Complete | Infra / Integration Lead |
| Module 1 — Horizon and core services | Complete | Infra / Integration Lead |
| Module 2 — Network topology | Not started | Network / Compute Lead |
| Module 3 — Web service | Not started | Network / Compute Lead |
| Module 4 — Swift and Cinder persistence | Not started | Storage / Automation Lead |
| Module 5 — Heat orchestration | Not started | Storage / Automation Lead |
| Final report and video | Not started | Shared; merged by Integration Lead |

## Environment

- OpenStack host: `192.168.2.10`
- Hostname: `openstack`
- OS: Ubuntu Server 24.04.4 LTS (`noble`)
- Capacity: 4 vCPU, 22 GiB RAM, 73 GiB root disk, 8 GiB swap
- DevStack branch: `stable/2026.1`
- DevStack commit: `da2f4d73f5ad74fc8ecfbe15bd7e20f6b0982dbb`
- Deployment: all-in-one
- Nova virtualization: nested KVM
- Optional services enabled during the initial deployment: Heat, Heat Dashboard, Swift
- Horizon: `http://192.168.2.10/dashboard`
- NetBird HTTPS entry point: `https://openstack.net.selfhost.io.vn/dashboard`

Ubuntu 24.04 was selected because it is supported by DevStack `stable/2026.1`. The assignment mentions Ubuntu 22.04; this difference must be disclosed in the report.

The NetBird HTTPS endpoint terminates TLS before proxying to Horizon. The live
Horizon settings trust this HTTPS origin and honor `X-Forwarded-Proto` and
`X-Forwarded-Host`; otherwise Django rejects login with a CSRF origin error.

## Credentials

Credentials are intentionally not committed to this public repository. Ask the Infra Lead through a private channel.

Copy the example configuration only when rebuilding:

```bash
cp devstack/local.conf.example devstack/local.conf
```

Never commit `devstack/local.conf`, OpenStack RC files, private keys, passwords, tokens, or `.env` files.

## Repository layout

```text
.
├── devstack/                 # Reproducible DevStack configuration example
├── shared/                   # Team rules, environment and health-check tooling
├── module1/                  # Complete CLI/Horizon evidence and automation
├── module2/                  # Network topology work area
├── module3/                  # Dual-NIC web-service work area
├── module4/                  # Swift/Cinder persistence work area
├── module5/                  # Heat template and cloud-init work area
└── report/                   # Final report, diagrams and selected screenshots
```

## Module 1 completion

Module 1 evidence covers:

- Compute Overview
- Instances
- Images
- Key Pairs
- Security Groups
- Networks
- Subnets
- Routers
- Heat Stacks
- Swift Containers
- CLI instance launch and deletion
- Horizon launch dialog, Active/Running instance, delete confirmation, and empty post-termination list

Files:

- CLI log: `module1/evidence/cli/module1-cli.log`
- Horizon screenshots: `module1/evidence/horizon/`
- CLI automation: `module1/run-module1-cli.sh`
- Screenshot automation: `module1/capture-horizon-evidence.py`

The Horizon UI lifecycle is complete: the instance was launched, reached Active/Running, deleted through the Horizon confirmation flow, and verified absent through both Horizon and OpenStack CLI.

## Team workflow

### Roles

- Infra / Integration Lead: platform health, Module 1, snapshots, evidence, repository and final integration.
- Network / Compute Lead: Modules 2–3, topology, router, security groups, floating IP and web service.
- Storage / Automation Lead: Modules 4–5, Swift, Cinder, snapshot recovery, Heat and cloud-init.

### Resource naming

Use module prefixes so ownership is obvious:

```text
m2-dmz-net
m2-private-net
m2-router
m2-web-sg
m3-web-server
m4-tetris-src
m4-data-volume
m4-data-snapshot
m5-*
```

### Operational safety

Do not run these commands on the shared lab:

```bash
./stack.sh
./unstack.sh
./clean.sh
```

Only the Infra Lead may restart OpenStack services, modify `/etc/nova` or `/etc/neutron`, reboot the OpenStack host, or change the Proxmox VM. Do not perform bulk deletion. Before deleting any resource, identify its owner and module prefix.

## Quick health check

After receiving credentials privately:

```bash
ssh newnol@192.168.2.10
cd ~/devstack
source openrc demo demo
openstack token issue
openstack compute service list
openstack hypervisor list
openstack network agent list
openstack image list
openstack orchestration service list
openstack container list
```

Or run:

```bash
./shared/health-check.sh
```

## Contribution workflow

Each member works on a branch:

```bash
git switch -c module2-network
# or module4-storage, module5-heat, etc.
```

Commit scripts, logs, screenshots and README updates together. Open a pull request into `main`. Do not force-push `main`, and do not commit credentials.

## Submission requirements

The final submission must include:

- `StudentID1-StudentID2-StudentID3 Report.pdf`
- `module2_diagram.png`
- `module5_service.yaml`
- `demo.txt` containing the video link
- Reproduction instructions for every module
- Environment details and the pinned DevStack branch

See each module README for its checklist and expected evidence.
