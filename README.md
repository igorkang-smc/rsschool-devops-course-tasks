# Flask CI/CD Demo with Jenkins, Kubernetes, and Kaniko

A complete CI/CD pipeline demonstration using Flask, Jenkins, Kubernetes (Minikube), Docker Hub, Kaniko, and Helm.

## 🎯 Overview

This project demonstrates a production-ready CI/CD pipeline that includes:

- **Application Build** - Python Flask application with proper error handling
- **Unit Testing** - Comprehensive test suite with coverage reporting
- **Security Scanning** - SonarQube integration for code quality and security
- **Container Building** - Kaniko for secure Docker image building in Kubernetes
- **Deployment** - Helm charts for Kubernetes deployment
- **Monitoring** - Application verification and smoke testing
- **Notifications** - Slack and email notifications for pipeline status

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Git Repository │    │     Jenkins     │    │   Kubernetes    │
│                 │────▶│                 │────▶│                 │
│  - Source Code  │    │  - Pipeline     │    │  - Application  │
│  - Jenkinsfile  │    │  - Kaniko Build │    │  - Helm Charts  │
│  - Tests        │    │  - SonarQube    │    │  - Monitoring   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   Docker Hub    │
                       │                 │
                       │  - Container    │
                       │    Images       │
                       └─────────────────┘
```

## 📋 Prerequisites

Ensure you have the following installed:

- Docker (20.10+)
- Minikube (1.25+)
- kubectl (1.24+)
- Helm (3.8+)
- Git
- Docker Hub Account

## 🚀 Quick Start

### 1. Clone and Setup Repository

```bash
git clone <repository-url>
cd flask-cicd-demo
git checkout -b task_6
```

### 2. Configure Docker Hub

Update:
- `Jenkinsfile` (line 42)
- `helm/flask-app/values.yaml` (line 7)

### 3. Setup Environment

```bash
chmod +x exec.sh
export DOCKER_HUB_USERNAME="your-dockerhub-username"
export DOCKER_HUB_PASSWORD="your-dockerhub-password"
./setup.sh
```

This will start Minikube, install Jenkins, SonarQube, create secrets & RBAC.

### 4. Access Services

- Jenkins: `http://$(minikube ip):32000` (admin/admin123)
- SonarQube: `http://$(minikube ip):32001` (admin/admin)
- Dashboard: `minikube dashboard`

## 🔧 Pipeline Configuration

Setup Jenkins Pipeline:

- New Item → Pipeline → Name: `flask-cicd-demo`
- SCM: Git → Branch: `*/task_6` → Script Path: `Jenkinsfile`
- Triggers: Poll SCM (`H/5 * * * *`) or Webhooks

SonarQube:

- Create Project `flask-cicd-demo`
- Generate Token and configure in Jenkins

## 📦 Application Structure

```
flask-cicd-demo/
├── app.py
├── requirements.txt
├── tests/
│   └── test_app.py
├── Dockerfile
├── Jenkinsfile
├── helm/
│   └── flask-app/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
├── sonar-project.properties
├── pytest.ini
├── setup.sh
└── README.md
```

## 🔄 Pipeline Stages

1. Checkout
2. Application Build
3. Unit Tests
4. Code Quality - SonarQube
5. Quality Gate
6. Docker Image Build & Push
7. Helm Chart Lint
8. Deploy to Kubernetes
9. Application Verification
10. Smoke Tests

## 🧪 Testing

```bash
pip install -r requirements.txt
pytest tests/ -v
pytest tests/ --cov=app --cov-report=html
pytest tests/test_app.py::TestFlaskApp::test_health_endpoint -v
```

Test app locally:

```bash
python app.py
curl http://localhost:5000/
curl http://localhost:5000/health
curl http://localhost:5000/api/status
curl http://localhost:5000/api/info
```

## 🐳 Docker Operations

```bash
docker build -t flask-cicd-demo:latest .
docker run -p 5000:5000 -e ENVIRONMENT=development flask-cicd-demo:latest
curl http://localhost:5000/health
```

## ☸️ Kubernetes Operations

```bash
helm lint helm/flask-app
helm upgrade --install flask-app helm/flask-app   --set image.repository=your-dockerhub-username/flask-cicd-demo   --set image.tag=latest
kubectl get pods
kubectl get services
kubectl port-forward svc/flask-app 8080:80
curl http://localhost:8080/health
```

## 📊 Monitoring and Troubleshooting

```bash
kubectl logs -f deployment/jenkins -n jenkins
kubectl logs -f deployment/sonarqube-sonarqube -n jenkins
kubectl get pods -l app=flask-cicd-demo
kubectl logs -l app=flask-cicd-demo
kubectl describe pod <pod-name>
kubectl get endpoints flask-app
```

## 🔔 Notifications

- **Slack**: configure Slack plugin, webhook, and `SLACK_CHANNEL`
- **Email**: setup Email Extension plugin, SMTP, and recipients

## 🛡️ Security Considerations

- Non-root containers, secure builds (Kaniko), minimal images
- RBAC, secrets management, network policies
- SonarQube for vulnerability scanning

## 🔧 Customization

### Environment Variables

| Variable     | Description             | Default     |
|--------------|-------------------------|-------------|
| APP_VERSION  | Application version     | 1.0.0       |
| ENVIRONMENT  | Deployment environment  | production  |
| LOG_LEVEL    | Logging level           | INFO        |
| PORT         | Application port        | 5000        |

### Helm Custom Values

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

## 🧹 Cleanup

```bash
./cleanup.sh

# Or manual
helm uninstall jenkins -n jenkins
helm uninstall sonarqube -n jenkins
kubectl delete namespace jenkins
minikube delete
```
