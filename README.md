# Flask CI/CD Demo with Jenkins, Kubernetes, and Kaniko

A complete CI/CD pipeline demonstration using Flask, Jenkins, Kubernetes (Minikube), Docker Hub, Kaniko, and Helm.

---

## 🎯 Overview

This project demonstrates a production-ready CI/CD pipeline that includes:

- **Application Build** – Python Flask application with proper error handling
- **Unit Testing** – Comprehensive test suite with coverage reporting
- **Security Scanning** – SonarQube integration for code quality and security
- **Container Building** – Kaniko for secure Docker image building in Kubernetes
- **Deployment** – Helm charts for Kubernetes deployment
- **Monitoring** – Application verification and smoke testing
- **Notifications** – Slack and email notifications for pipeline status

---

## 🏗️ Architecture

```plaintext
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Git Repository  │    │     Jenkins     │    │   Kubernetes    │
│ - Source Code   │───▶│ - Pipeline       │───▶│ - Application   │
│ - Jenkinsfile   │    │ - Kaniko Build   │    │ - Helm Charts   │
│ - Tests         │    │ - SonarQube      │    │ - Monitoring    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │
         ▼
 ┌─────────────────┐
 │   Docker Hub    │
 │ - Container     │
 │   Images        │
 └─────────────────┘
```

---

## 📋 Prerequisites

Ensure the following tools are installed:

- Docker (20.10+)
- Minikube (1.25+)
- kubectl (1.24+)
- Helm (3.8+)
- Git
- Docker Hub account

---

## 🚀 Quick Start

### Clone and Setup Repository

```bash
git clone <your-repository-url>
cd flask-cicd-demo
git checkout -b task_6
```

### Configure Docker Hub

Update these files:

- `Jenkinsfile` (line 42): Replace `your-dockerhub-username`
- `helm/flask-app/values.yaml` (line 7): Replace `your-dockerhub-username`

### Setup Environment

```bash
chmod +x setup.sh
export DOCKER_HUB_USERNAME="your-dockerhub-username"
export DOCKER_HUB_PASSWORD="your-dockerhub-password"
./setup.sh
```

This script will:

- Start Minikube with required addons
- Install Jenkins with plugins
- Install SonarQube
- Create Kubernetes secrets and RBAC
- Configure all services

---

## 🔑 Access Services

- Jenkins: `http://<minikube ip>:32001`
    - Username: `admin`
    - Password: `admin`
- Kubernetes Dashboard: `minikube dashboard`

---

## 🔧 Jenkins Pipeline Configuration

### Setup Pipeline

1. Access Jenkins
2. Click **"New Item"**
3. Choose **"Pipeline"** project
4. Name it `flask-cicd-demo`

### Configure:

- **Pipeline script from SCM**
    - SCM: Git
    - URL: Your repo
    - Branch: `*/task_6`
    - Script Path: `Jenkinsfile`

### Triggers:

- Enable **Poll SCM**:
  ```
  H/5 * * * * 
  ```  
  Or configure webhooks.

...