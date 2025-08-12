#!/bin/bash

# Kubernetes Cluster Setup Script
# This script sets up a 3-node Kubernetes cluster using kind
# Features: 1 control-plane node, 2 worker nodes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install kubectl
install_kubectl() {
    if ! command_exists kubectl; then
        print_status "Installing kubectl..."
        
        # Detect OS
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
            chmod +x kubectl
            sudo mv kubectl /usr/local/bin/
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
            chmod +x kubectl
            sudo mv kubectl /usr/local/bin/
        else
            print_error "Unsupported OS. Please install kubectl manually."
            exit 1
        fi
    else
        print_status "kubectl is already installed"
    fi
}

# Function to install kind
install_kind() {
    if ! command_exists kind; then
        print_status "Installing kind..."
        
        # Detect OS
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux
            curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
            chmod +x ./kind
            sudo mv ./kind /usr/local/bin/kind
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-darwin-amd64
            chmod +x ./kind
            sudo mv ./kind /usr/local/bin/kind
        else
            print_error "Unsupported OS. Please install kind manually."
            exit 1
        fi
    else
        print_status "kind is already installed"
    fi
}

# Function to check if cluster exists
cluster_exists() {
    kind get clusters | grep -q "devops-cluster"
}

# Function to create cluster
create_cluster() {
    print_status "Creating Kubernetes cluster with 3 nodes..."
    
    # Create kind configuration
    cat > kind-config.yaml << EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
- role: worker
networking:
  apiServerAddress: "127.0.0.1"
  apiServerPort: 6443
EOF

    # Create cluster
    kind create cluster --name devops-cluster --config kind-config.yaml
    
    # Wait for cluster to be ready
    print_status "Waiting for cluster to be ready..."
    kubectl wait --for=condition=Ready nodes --all --timeout=300s
    
    print_status "Cluster created successfully!"
}

# Function to verify cluster
verify_cluster() {
    print_status "Verifying cluster status..."
    
    echo "Cluster nodes:"
    kubectl get nodes -o wide
    
    echo -e "\nCluster info:"
    kubectl cluster-info
    
    echo -e "\nSystem pods:"
    kubectl get pods -n kube-system
}

# Function to install Docker if not present (for Linux)
check_docker() {
    if ! command_exists docker; then
        print_warning "Docker is not installed. Please install Docker first."
        print_warning "Visit: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    # Check if Docker daemon is running
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker daemon is not running. Please start Docker first."
        exit 1
    fi
    
    print_status "Docker is available and running"
}

# Main execution
main() {
    print_status "Starting Kubernetes cluster setup..."
    
    # Check prerequisites
    check_docker
    
    # Install tools if needed
    install_kubectl
    install_kind
    
    # Check if cluster already exists
    if cluster_exists; then
        print_warning "Cluster 'devops-cluster' already exists."
        read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Deleting existing cluster..."
            kind delete cluster --name devops-cluster
            create_cluster
        else
            print_status "Using existing cluster..."
        fi
    else
        create_cluster
    fi
    
    # Verify cluster
    verify_cluster
    
    print_status "Cluster setup completed successfully!"
    print_status "You can now deploy applications to your cluster."
    print_status "To access the cluster: kubectl cluster-info"
}

# Run main function
main "$@" 