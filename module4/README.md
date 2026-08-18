# Module 4 — Swift and Cinder Persistence

Owner: Storage / Automation Lead

## Goal

Upload application source to Swift, attach and mount a Cinder volume, deploy the source to that volume, snapshot it, restore a new volume from the snapshot, attach it to another instance, and prove persistence.

## Resource names

```text
m4-tetris-src
m4-data-volume
m4-data-snapshot
m4-restored-volume
m4-recovery-server
```

## Dependency

Before integrating with a guest, confirm that the Module 3 VM can reach the Swift endpoint. Distinguish routing failures from authentication failures.

## Deliverables

- `swift.sh`
- `cinder.sh`
- `restore-from-snapshot.sh`
- application source
- CLI logs and Horizon screenshots under `evidence/`

## Verification checklist

```bash
openstack container list
openstack object list m4-tetris-src
openstack volume list
openstack volume snapshot list
openstack server show m4-recovery-server
```

Evidence must show the original volume, snapshot, restored volume, attachment to the second VM, and the recovered application data.
