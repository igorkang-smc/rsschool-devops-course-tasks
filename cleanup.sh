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
