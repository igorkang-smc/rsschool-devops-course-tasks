# Flask CI/CD Demo - Minikube Setup Script
# This script sets up the complete environment for Jenkins CI/CD pipeline

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOCKER_HUB_USERNAME="${DOCKER_HUB_USERNAME:-your-dockerhub-username}"
JENKINS_NAMESPACE="jenkins"
APP_NAMESPACE="default"

echo -e "${BLUE}🚀 Setting up Flask CI/CD Demo Environment${NC}"
echo "=================================="

# Function to print status
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check prerequisites
echo -e "${BLUE}📋 Checking prerequisites...${NC}"

check_command() {
    if command -v $1 &> /dev/null; then
        print_status "$1 is installed"
    else
        print_error "$1 is not installed. Please install it first."
        exit 1
    fi
}

check_command "minikube"
check_command "kubectl"
check_command "helm"
check_command "docker"

# Start Minikube if not running
echo -e "\n${BLUE}🎯 Starting Minikube...${NC}"
if minikube status | grep -q "Running"; then
    print_status "Minikube is already running"
else
    minikube start --driver=docker --cpus=4 --memory=6144 --disk-size=20g
    print_status "Minikube started successfully"
fi

# Enable required addons
echo -e "\n${BLUE}🔧 Enabling Minikube addons...${NC}"
minikube addons enable ingress
minikube addons enable dashboard
minikube addons enable metrics-server
print_status "Minikube addons enabled"

# Set kubectl context
kubectl config use-context minikube
print_status "kubectl context set to minikube"

# Create namespaces
echo -e "\n${BLUE}📁 Creating namespaces...${NC}"
kubectl create namespace ${JENKINS_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace ${APP_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
print_status "Namespaces created"

# Create Docker registry secret (you'll need to update this with your credentials)
echo -e "\n${BLUE}🔑 Creating Docker registry secret...${NC}"
print_warning "Please update the Docker Hub credentials in the script or set environment variables:"
print_warning "DOCKER_HUB_USERNAME and DOCKER_HUB_PASSWORD"

if [[ -n "${DOCKER_HUB_PASSWORD}" ]]; then
    kubectl create secret docker-registry docker-registry-secret \
        --docker-server=docker.io \
        --docker-username=${DOCKER_HUB_USERNAME} \
        --docker-password=${DOCKER_HUB_PASSWORD} \
        --namespace=${JENKINS_NAMESPACE} \
        --dry-run=client -o yaml | kubectl apply -f -
    
    kubectl create secret docker-registry docker-registry-secret \
        --docker-server=docker.io \
        --docker-username=${DOCKER_HUB_USERNAME} \
        --docker-password=${DOCKER_HUB_PASSWORD} \
        --namespace=${APP_NAMESPACE} \
        --dry-run=client -o yaml | kubectl apply -f -
    
    print_status "Docker registry secret created"
else
    print_warning "Docker Hub password not provided. You'll need to create the secret manually:"
    echo "kubectl create secret docker-registry docker-registry-secret \\"
    echo "  --docker-server=docker.io \\"
    echo "  --docker-username=YOUR_USERNAME \\"
    echo "  --docker-password=YOUR_PASSWORD \\"
    echo "  --namespace=${JENKINS_NAMESPACE}"
    echo ""
    echo "kubectl create secret docker-registry docker-registry-secret \\"
    echo "  --docker-server=docker.io \\"
    echo "  --docker-username=YOUR_USERNAME \\"
    echo "  --docker-password=YOUR_PASSWORD \\"
    echo "  --namespace=${APP_NAMESPACE}"
fi

# Install Jenkins using Helm
echo -e "\n${BLUE}🏗️ Installing Jenkins...${NC}"

# Add Jenkins Helm repository
helm repo add jenkins https://charts.jenkins.io
helm repo update

echo -e "\n${BLUE}📦 Applying PVC and ServiceAccount...${NC}"
kubectl apply -f jenkins-01.yaml -n ${JENKINS_NAMESPACE}
kubectl apply -f jenkins-02.yaml -n ${JENKINS_NAMESPACE}
print_status "PVC and ServiceAccount applied"

# Fix permissions for Jenkins hostPath volume inside Minikube
echo -e "\n${BLUE}🛠️ Fixing permissions for Jenkins hostPath volume...${NC}"
minikube ssh -- "sudo mkdir -p /data/jenkins-volume && sudo chown -R 1000:1000 /data/jenkins-volume"
print_status "Permissions for /data/jenkins-volume fixed (UID 1000)"

# Install Jenkins
helm upgrade --install jenkins jenkins/jenkins \
  --namespace ${JENKINS_NAMESPACE} \
  -f jenkins-values.yaml \
  --wait --timeout=20m

print_status "Jenkins installed successfully"

# Install SonarQube (optional but recommended)
echo -e "\n${BLUE}📊 Installing SonarQube...${NC}"

helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo update

cat > sonarqube-values.yaml << EOF
community:
  enabled: true

monitoringPasscode: "myMonitoringPass123"

postgresql:
  enabled: true
  auth:
    postgresPassword: sonarPass
    database: sonarqube

service:
  type: NodePort
  port: 9000
  nodePort: 32001

resources:
  requests:
    cpu: "500m"
    memory: "1Gi"
  limits:
    cpu: "1000m"
    memory: "2Gi"

persistence:
  enabled: true
  size: "5Gi"
EOF

helm upgrade --install sonarqube sonarqube/sonarqube \
    --namespace ${JENKINS_NAMESPACE} \
    --values sonarqube-values.yaml \
    --wait --timeout=20m

print_status "SonarQube installed successfully"

# Wait for services to be ready
echo -e "\n${BLUE}⏳ Waiting for services to be ready...${NC}"

kubectl rollout status statefulset/jenkins -n ${JENKINS_NAMESPACE} --timeout=600s
kubectl rollout status statefulset/sonarqube-sonarqube -n ${JENKINS_NAMESPACE} --timeout=600s

print_status "All services are ready"

# Get access information
echo -e "\n${BLUE}📋 Access Information${NC}"
echo "=================================="

# Jenkins access
JENKINS_URL="http://$(minikube ip):32000"
echo -e "🔧 ${GREEN}Jenkins:${NC}"
echo "   URL: ${JENKINS_URL}"
echo "   Username: admin"
echo "   Password: admin123"
echo ""

# SonarQube access
SONARQUBE_URL="http://$(minikube ip):32001"
echo -e "📊 ${GREEN}SonarQube:${NC}"
echo "   URL: ${SONARQUBE_URL}"
echo "   Username: admin"
echo "   Password: admin"
echo ""

# Minikube dashboard
echo -e "📊 ${GREEN}Kubernetes Dashboard:${NC}"
echo "   Run: minikube dashboard"
echo ""

# Useful commands
echo -e "${BLUE}📝 Useful Commands${NC}"
echo "=================================="
echo "# Access Jenkins logs:"
echo "kubectl logs -f deployment/jenkins -n ${JENKINS_NAMESPACE}"
echo ""
echo "# Access SonarQube logs:"
echo "kubectl logs -f deployment/sonarqube-sonarqube -n ${JENKINS_NAMESPACE}"
echo ""
echo "# Port forward Jenkins (alternative access):"
echo "kubectl port-forward svc/jenkins 8080:8080 -n ${JENKINS_NAMESPACE}"
echo ""
echo "# Port forward SonarQube (alternative access):"
echo "kubectl port-forward svc/sonarqube-sonarqube 9000:9000 -n ${JENKINS_NAMESPACE}"
echo ""
echo "# Check all pods:"
echo "kubectl get pods -A"
echo ""
echo "# Clean up everything:"
echo "minikube delete"

echo -e "\n${GREEN}🎉 Setup completed successfully!${NC}"
echo ""
print_warning "Next steps:"
echo "1. Access Jenkins and configure your pipeline"
echo "2. Update Docker Hub credentials in Jenkinsfile"
echo "3. Configure SonarQube project"
echo "4. Create your git repository and push the code"
echo "5. Set up webhooks for automatic builds"

# Create a cleanup script
cat > cleanup.sh << 'EOF'
#!/bin/bash

echo "🧹 Cleaning up Flask CI/CD Demo Environment..."

# Delete Helm releases
helm uninstall jenkins -n jenkins
helm uninstall sonarqube -n jenkins

# Delete namespaces
kubectl delete namespace jenkins --ignore-not-found=true

# Delete RBAC
kubectl delete clusterrole jenkins-admin --ignore-not-found=true
kubectl delete clusterrolebinding jenkins-admin --ignore-not-found=true

# Remove generated files
rm -f jenkins-values.yaml sonarqube-values.yaml jenkins-rbac.yaml

echo "✅ Cleanup completed!"
echo "To completely remove minikube: minikube delete"
EOF

chmod +x cleanup.sh
print_status "Cleanup script created (cleanup.sh)"