#!/bin/bash

# Kubernetes Deployment Script
# This script deploys all Kubernetes components

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    print_error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
    exit 1
fi

print_status "Starting Kubernetes deployment..."

# Create namespaces
print_status "Creating namespaces..."
kubectl apply -f namespace.yaml
kubectl apply -f monitoring-namespace.yaml

# Install NGINX Ingress Controller
print_status "Installing NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/kind/deploy.yaml

# Wait for ingress controller to be ready
print_status "Waiting for NGINX Ingress Controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

# Deploy monitoring components
print_status "Deploying monitoring components..."
kubectl apply -f monitoring-namespace.yaml
kubectl apply -f prometheus-config.yaml
kubectl apply -f prometheus-deployment.yaml
kubectl apply -f grafana-deployment.yaml

# Wait for monitoring pods to be ready
print_status "Waiting for monitoring pods to be ready..."
kubectl wait --namespace monitoring \
  --for=condition=ready pod \
  --selector=app=prometheus \
  --timeout=300s

kubectl wait --namespace monitoring \
  --for=condition=ready pod \
  --selector=app=grafana \
  --timeout=300s

# Deploy application components
print_status "Deploying application components..."
kubectl apply -f rbac.yaml
kubectl apply -f secrets.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f network-policy.yaml

# Wait for application pods to be ready
print_status "Waiting for application pods to be ready..."
kubectl wait --namespace hello-world-app \
  --for=condition=ready pod \
  --selector=app=hello-world-app \
  --timeout=300s

# Deploy ingress
print_status "Deploying ingress..."
kubectl apply -f ingress.yaml

# Wait for ingress to be ready
print_status "Waiting for ingress to be ready..."
kubectl wait --namespace hello-world-app \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

# Display deployment status
print_status "Deployment completed successfully!"
echo ""
echo "=== Deployment Status ==="
echo "Application pods:"
kubectl get pods -n hello-world-app

echo ""
echo "Monitoring pods:"
kubectl get pods -n monitoring

echo ""
echo "Services:"
kubectl get services -n hello-world-app
kubectl get services -n monitoring

echo ""
echo "Ingress:"
kubectl get ingress -n hello-world-app

echo ""
print_status "Access URLs:"
echo "Application: http://hello-world.local"
echo "Prometheus: http://localhost:9090 (port-forward required)"
echo "Grafana: http://localhost:3000 (port-forward required)"
echo ""
echo "To access Prometheus: kubectl port-forward -n monitoring svc/prometheus-service 9090:9090"
echo "To access Grafana: kubectl port-forward -n monitoring svc/grafana-service 3000:3000"
echo "Grafana credentials: admin/admin123" 