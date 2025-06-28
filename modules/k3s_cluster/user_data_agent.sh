#!/bin/bash
set -euo pipefail

# Enable SELinux policies required by k3s on Amazon Linux 2
amazon-linux-extras enable selinux-ng
yum clean metadata
yum install -y selinux-policy-targeted

# Install k3s agent and join the cluster
export K3S_URL="https://${server_private_ip}:6443"
export K3S_TOKEN="${cluster_token}"
curl -sfL https://get.k3s.io | sh -

# Print node status for troubleshooting
/usr/local/bin/k3s kubectl get nodes -o wide
