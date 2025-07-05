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

# Jenkins using Minikube

1. Install [Helm](https://helm.sh/docs/intro/install/)
2. Install [Minikube](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fwindows%2Fx86-64%2Fstable%2F.exe+download)
3. Start cluster `minikube start`.
4. Add Jenkins to Helm repo

```bash
helm repo add jenkinsci https://charts.jenkins.io
helm repo update
```

5. Create namespace and apply PV and PVC:

```bash
kubectl create namespace jenkins
kubectl apply -f jenkins-01.yaml
kubectl apply -f jenkins-02.yaml
```

6. Install Jenkins:

```bash
helm install jenkins jenkinsci/jenkins -n jenkins -f jenkins-values.yaml
```

[Jenkins](https://www.jenkins.io/doc/book/installing/kubernetes/#install-jenkins-with-helm-v3)

```
kubectl port-forward svc/jenkins -n jenkins 8080:8080
```

8. Use `http://localhost:8080` to open Jenkins web-page
9. Use credentials (set in values.yaml):

   user: admin

   password: strong-admin-password