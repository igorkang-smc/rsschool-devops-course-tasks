# Flask CI/CD Demo with Jenkins, Kubernetes, and Kaniko

A complete CI/CD pipeline demonstration using Flask, Jenkins, Kubernetes (Minikube), Docker Hub, Kaniko, SonarQube, and Helm — with monitoring (Grafana, Prometheus) and alerting (Mailhog, Alertmanager).

---

## 🌟 Overview

This project demonstrates a full-featured, production-grade CI/CD pipeline including:

* **Build**: Python Flask app with error handling
* **Test**: Unit tests with coverage report
* **Scan**: SonarQube for static code analysis
* **Build & Push**: Secure container image builds using Kaniko
* **Deploy**: Helm charts for Kubernetes
* **Monitor**: Prometheus, Grafana dashboards, alerting via Mailhog
* **Notify**: Slack/email notifications

---

## 🏠 Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Git Repository │    │     Jenkins     │    │   Kubernetes    │
│                 │────▶│                 │────▶│                 │
│  - Source Code  │    │  - Pipeline     │    │  - Flask App    │
│  - Jenkinsfile  │    │  - Kaniko Build │    │  - Helm Charts  │
│  - Tests        │    │  - SonarQube    │    │  - Monitoring   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   Docker Hub    │
                       │                 │
                       │  - Images       │
                       └─────────────────┘
```

---

## 📄 Prerequisites

* Docker 20.10+
* Minikube 1.25+
* kubectl 1.24+
* Helm 3.8+
* Git
* Docker Hub Account

---

## 🚀 Quick Start

### 1. Clone and Checkout Task Branch

```bash
git clone <repository-url>
git checkout -b task_7
```

### 2. Configure Docker Hub Credentials

Update:

* `Jenkinsfile` → set username and password
* `helm/flask-app/values.yaml` → set image repository

### 3. Run Setup Script

```bash
chmod +x exec.sh
export DOCKER_HUB_USERNAME="your-dockerhub-username"
export DOCKER_HUB_PASSWORD="your-dockerhub-password"
kubectl -n monitoring create secret generic grafana-admin-secret \
  --from-literal=admin='admin' \
  --from-literal=strong-admin-password='admin'

./exec.sh
```

Installs:

* Jenkins, SonarQube
* Grafana, Prometheus, Alertmanager
* Mailhog
* Secrets, RBAC

### 4. Access Services

| Service   | URL                                | Default Login         |
| --------- | ---------------------------------- | --------------------- |
| Jenkins   | `http://$(minikube ip):32000`      | admin / admin123      |
| SonarQube | `http://$(minikube ip):32001`      | admin / admin         |
| Grafana   | `http://$(minikube ip):<NodePort>` | admin / set in secret |
| Mailhog   | `http://$(minikube ip):<NodePort>` | -                     |
| Dashboard | `minikube dashboard`               |                       |

---

## 🛠️ Jenkins Pipeline Setup

1. Jenkins → New Item → Pipeline → `flask-cicd-demo`
2. Configure:

    * Branch: `*/task_7`
    * Script path: `Jenkinsfile`
3. Trigger: Poll SCM `H/5 * * * *` or via webhook
4. Create SonarQube project and token, configure in Jenkins credentials

---

## 📦 Application Structure

```
flask-cicd-demo/
├── app.py
├── requirements.txt
├── tests/
├── Dockerfile
├── Jenkinsfile
├── helm/
│   └── flask-app/
├── monitoring/
│   ├── grafana-values.yaml
│   └── *
├── sonar-project.properties
├── exec.sh
└── README.md
```

---

## ♻️ Pipeline Stages

1. Checkout source
2. Build Flask app
3. Run unit tests
4. SonarQube scan
5. Wait for Quality Gate
6. Build & push image with Kaniko
7. Helm lint & deploy
8. Pod readiness + health checks
9. Smoke tests
10. Notify via Slack/email

---

## 🤞 Troubleshooting Notes

### ❗ `CreateContainerConfigError` in Grafana

Ensure the required secret exists:

```bash
kubectl -n monitoring create secret generic grafana-admin-secret \
  --from-literal=admin='admin' \
  --from-literal=strong-admin-password='StrongGrafanaPass!'
```

### ❗ Pod "Pending" in Jenkins Agent

Check container image pull / volume mounts / missing secrets. Fix with:

* Smaller pod templates per stage
* Use `imagePullPolicy: IfNotPresent`
* Pre-pull images with `minikube image load ...`
* Use images with `/bin/sh` for shell execution in `sh {}`

Example fix for `kubectl`:

```yaml
- name: kubectl
  image: lachlanevenson/k8s-kubectl:v1.30.0
  command: ["sleep", "99d"]
  tty: true
```

---

## 🔮 Test Locally

```bash
python app.py
curl http://localhost:5000/
curl http://localhost:5000/health
```

Run tests:

```bash
pip install -r requirements.txt
pytest tests/ -v --cov=app --cov-report=html
```

---

## 🛥️ Kubernetes Deployment

```bash
helm lint helm/flask-app
helm upgrade --install flask-app helm/flask-app \
  --set image.repository=your-dockerhub-username/flask-cicd-demo \
  --set image.tag=latest
kubectl get pods
kubectl port-forward svc/flask-app 8080:80
curl http://localhost:8080/health
```

---

## 📊 Monitoring

* **Grafana**:

    * View dashboards (NodePort or port-forward)
    * Uses `grafana-values.yaml` with Prometheus as datasource

* **Prometheus & Alertmanager**:

    * Installed via Helm
    * Integrated with Grafana

* **Mailhog**:

    * Captures alerts over SMTP for test

---

## 🔔 Notifications

* Slack: configure plugin + webhook
* Email: set SMTP env vars in `exec.sh` and configure in Jenkins

---

## 🚧 Cleanup

```bash
./cleanup.sh
# Or manually:
helm uninstall jenkins -n jenkins
helm uninstall sonarqube -n jenkins
helm uninstall my-grafana -n monitoring
kubectl delete ns jenkins monitoring
minikube delete
```

---

## 📁 Environment Variables

| Variable              | Description                  |
| --------------------- | ---------------------------- |
| `DOCKER_HUB_USERNAME` | Docker Hub login             |
| `DOCKER_HUB_PASSWORD` | Docker Hub token/password    |
| `ADMIN_PASS`          | SonarQube/Grafana admin pass |
| `SMTP_*`              | Mail SMTP credentials        |

---

## 🔧 Helm Customization (Example)

```yaml
replicaCount: 3
resources:
  requests:
    cpu: 500m
    memory: 512Mi
  limits:
    cpu: 1000m
    memory: 1Gi
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
```

---

Made with ❤️ by \[Your Name]
