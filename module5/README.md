# Module 5 — Heat Orchestration

Owner: Storage / Automation Lead

## Goal

Deploy the service through a Heat Orchestration Template that creates networking, router, security group, server, Cinder volume, attachment, floating IP and cloud-init/userdata configuration.

## Isolation requirement

Use an independent `m5-*` namespace. Do not import or manage the manually created Module 2–4 resources. Deleting the Heat stack must not destroy earlier module evidence.

## Expected resources

```text
m5-net
m5-subnet
m5-router
m5-secgroup
m5-server
m5-volume
m5-floating-ip
module5-service-stack
```

## Deliverables

- `service.yaml` — final submission copy also placed at repository root as `module5_service.yaml`
- `cloud-init.yaml` or inline Heat userdata
- `deploy.sh`
- `evidence/stack-create.txt`
- `evidence/stack-output.txt`
- `evidence/web-running.png`

## Verification

```bash
openstack stack create -t module5/service.yaml module5-service-stack
openstack stack event list module5-service-stack
openstack stack resource list module5-service-stack
openstack stack output show module5-service-stack --all
curl -v http://<stack-floating-ip>/
```

Parameterize image, flavor, external network and key environment-specific values. Validate before deployment:

```bash
openstack orchestration template validate -t module5/service.yaml
```
