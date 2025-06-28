# k3s Kubernetes Cluster on AWS

This document describes how the k3s cluster including bastion host has been provisioned with Terraform, and how to verify it.

## Architecture

```
┌────────────┐      ssh        ┌──────────────────┐   6443  ┌──────────────────┐
│  Laptop    ├────────────────►   Bastion/NAT     ├────────►  k3s-server       │
└────────────┘                  (public subnet)   │          (private subnet)  │
                                              ▲   │                          │
                                              │   │                          │
                                              │   └────────►  k3s-agent      │
                                              │              (private)       │
                                              │
                                 internet ↔ NAT ┘
```

* `k3s_server` – control-plane node (private)
* `k3s_agent`  – worker node (private)
* `nat_bastion` – single EC2 instance acting both as jump-host and NAT so that private nodes can reach the internet (for images).

## Files Added

* `modules/k3s_cluster/*` – reusable module that launches 1 server + 1 agent, installs k3s via user-data and outputs their private IPs.
* `k3s_cluster.tf` – root module call that wires subnets, SGs, and instance parameters.
* Security-group rule updated to allow port 6443 from bastion to workers.
* Bastion `user_data_nat.sh` extended to install `kubectl`.

## Deploy

```bash
terraform init
terraform apply -var-file=terraform.tfvars
```

Outputs will include the server private IP. SSH to bastion, then list nodes:

```bash
ssh -i <key>.pem ec2-user@<bastion_ip>

# inside bastion
kubectl get nodes -o wide
```

## Workload test

```bash
kubectl apply -f https://k8s.io/examples/pods/simple-pod.yaml
kubectl get all --all-namespaces
```

You should see an `nginx` pod in `default` namespace and two Ready nodes.

## SELinux on Amazon Linux 2

User-data for both server and agent enables the `selinux-ng` extras repo and installs `selinux-policy-targeted` to satisfy k3s requirements.

---

When finished:

```bash
terraform destroy -var-file=terraform.tfvars
```
