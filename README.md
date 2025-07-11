
# Flask Application Deployment with Helm - Complete Guide

Deploy a containerized Flask application to Kubernetes using Helm charts and Minikube for local development.

---

## What You'll Build

A complete deployment pipeline that takes a Flask web application from source code to running container in a Kubernetes cluster, managed through Helm charts.

## Architecture Overview

```
Flask App → Docker Image → Helm Chart → Kubernetes Cluster (Minikube)
```

The Flask application runs on port 8080 and serves HTTP requests through a Kubernetes NodePort service.

---

## Directory Structure

```
project-root/
├── flask_app/
│   ├── main.py           # Core Flask application
│   ├── requirements.txt  # Python package dependencies
│   └── Dockerfile        # Container build configuration
└── flask-chart/
    ├── Chart.yaml        # Helm chart metadata
    ├── charts/           # Chart dependencies (empty)
    ├── templates/
    │   ├── NOTES.txt     # Post-install instructions
    │   ├── _helpers.tpl  # Template helpers
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   └── ingress.yaml  # (optional)
    └── values.yaml       # Default configuration values
```

---

## Required Tools

Before starting, ensure you have these tools installed:

| Tool | Purpose | Installation Link |
|------|---------|-------------------|
| **Minikube** | Local Kubernetes cluster | [minikube.sigs.k8s.io](https://minikube.sigs.k8s.io/docs/start/) |
| **kubectl** | Kubernetes command-line tool | [kubernetes.io](https://kubernetes.io/docs/tasks/tools/) |
| **Helm** | Kubernetes package manager | [helm.sh](https://helm.sh/docs/intro/install/) |
| **Docker** | Container runtime | [docs.docker.com](https://docs.docker.com/get-docker/) |

---

## Step-by-Step Deployment

### Step 1: Initialize Your Environment

Launch your local Kubernetes cluster:

```bash
minikube start
```

Verify the cluster is running:

```bash
kubectl cluster-info
```

### Step 2: Build the Container Image

Navigate to your Flask application directory:

```bash
cd flask_app
```

Configure Docker to use Minikube's Docker daemon (this ensures the image is available inside the cluster):

```bash
eval $(minikube docker-env)
```

Build the Docker image:

```bash
docker build -t flask-app:v1.0.0 .
```

Verify the image was created:

```bash
docker images | grep flask-app
```

### Step 3: Configure the Helm Chart

Return to the project root:

```bash
cd ..
```

Generate a new Helm chart (if you haven't already):

```bash
helm create flask-chart
```

Update the `flask-chart/values.yaml` file with your application settings:

```yaml
# Container image configuration
image:
  repository: flask-app
  tag: v1.0.0
  pullPolicy: IfNotPresent

# Service configuration
service:
  type: NodePort
  port: 8080
  targetPort: 8080

# Disable ingress for local development
ingress:
  enabled: false

# Resource limits (optional)
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi
```

### Step 4: Deploy Using Helm

Install or upgrade your application:

```bash
helm upgrade --install flask-release ./flask-chart
```

The `--install` flag will create the release if it doesn't exist, or upgrade it if it does.

### Step 5: Verify Your Deployment

Check the Helm release status:

```bash
helm list
```

Verify Kubernetes resources:

```bash
# Check pods
kubectl get pods

# Check services
kubectl get services

# Check deployments
kubectl get deployments
```

Monitor pod logs to ensure the application started correctly:

```bash
kubectl logs -l app.kubernetes.io/name=flask-chart
```

Look for Flask startup messages:

```
* Serving Flask app 'main'
* Debug mode: off
* Running on http://0.0.0.0:8080
```

### Step 6: Access Your Application

Get the service URL:

```bash
minikube service flask-release-flask-chart --url
```

This command will output a URL like `http://192.168.49.2:30001`. Open this URL in your browser to access your Flask application.

Alternative method using port forwarding:

```bash
kubectl port-forward svc/flask-release-flask-chart 8080:8080
```

Then access the app at `http://localhost:8080`.

---

## Troubleshooting

### Common Issues

**Pod not starting:**
```bash
kubectl describe pod <pod-name>
```

**Image pull errors:**
```bash
# Ensure you're using Minikube's Docker daemon
eval $(minikube docker-env)
docker images | grep flask-app
```

**Service not accessible:**
```bash
# Check service endpoints
kubectl get endpoints
```



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
