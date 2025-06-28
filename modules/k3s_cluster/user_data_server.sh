#!/bin/bash
set -euo pipefail

# Enable SELinux policies required by k3s on Amazon Linux 2
amazon-linux-extras enable selinux-ng
yum clean metadata
yum install -y selinux-policy-targeted

# Install k3s in server (control-plane) mode
export K3S_TOKEN="${cluster_token}"
# Persist the kubeconfig with relaxed permissions so the bastion host user can read it
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh -

# Print some basic info for troubleshooting
/usr/local/bin/k3s kubectl apply -f https://k8s.io/examples/pods/simple-pod.yaml
/usr/local/bin/k3s kubectl get nodes -o wide
