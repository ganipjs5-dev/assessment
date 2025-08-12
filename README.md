# DevOps Technical Assessment From Sai Ganesh 

This repository contains a complete implementation of a cloud-native infrastructure and application deployment solution, demonstrating skills in Kubernetes, Docker, CI/CD, monitoring, security, and Infrastructure as Code.

# Note : Since i Dont  have infra from  i have write indetails output and instraction here hopefully agree this. 

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Setup Instructions](#detailed-setup-instructions)
- [Security Implementation](#security-implementation)
- [Monitoring & Observability](#monitoring--observability)
- [CI/CD Pipeline](#cicd-pipeline)
- [Infrastructure as Code](#infrastructure-as-code)
- [Troubleshooting](#troubleshooting)

## 🏗️ Overview

This assessment demonstrates:

### Part I: Kubernetes Setup & Operations
- ✅ **Dockerized Node.js Application** with multi-stage build and security best practices
- ✅ **3-node Kubernetes Cluster** using kind with automated setup script
- ✅ **Application Deployment** with NGINX Ingress, resource limits, and health checks
- ✅ **Monitoring & Observability** with Prometheus and Grafana
- ✅ **CI/CD Pipeline** with GitHub Actions including security scanning and rollback
- ✅ **Security Best Practices** including RBAC, Network Policies, and Secrets Management

### Part II: AWS Infrastructure as Code
- ✅ **VPC & Networking Module** with 3 public + 3 private subnets across multiple AZs
- ✅ **EC2 Provisioning Module** with bastion host setup
- ✅ **Remote State Management** using S3 and DynamoDB
- ✅ **Reusable Terraform Modules** following best practices

## ��️ Architecture

### Visual Architecture Diagrams

For detailed visual representations of the infrastructure, please refer to:


### Kubernetes Architecture Overview

- **[Kubernetes Architecture Diagram](https://github.com/ganipjs5-dev/assessment/blob/main/img/Kubernetes_Architecture.png)** - Shows the complete Kubernetes cluster setup with ingress, services, and monitoring components


### AWS Infrastructure Architecture Overview


- **[AWS Architecture Diagram](https://github.com/ganipjs5-dev/assessment/blob/main/img/aws_architecture.png)** - Illustrates the AWS VPC layout with public and private subnets, EC2 instances, and networking components


## 📋 Prerequisites

Before you begin, make sure you have the following prerequisites installed and configured on your system. This setup has been tested on various operating systems, but some steps may vary slightly depending on your environment.

### System Requirements

**Hardware Requirements:**
- **RAM**: Minimum 8GB available memory (16GB recommended for smooth operation)
- **Storage**: At least 20GB of free disk space for Docker images, Kubernetes data, and Terraform state files
- **CPU**: Multi-core processor (2+ cores recommended)

**Operating System Support:**
- **Linux**: Ubuntu 20.04+, CentOS 8+, or similar distributions
- **macOS**: macOS 10.15+ (Catalina or later)
- **Windows**: Windows 10/11 with WSL2 enabled (Windows Subsystem for Linux 2)

### Required Software Installation

#### 1. Docker Installation
Docker is essential for building and running containers. We'll use it for both the application and the local Kubernetes cluster.

**For Ubuntu/Debian:**
```bash
# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

# Add your user to docker group (requires logout/login)
sudo usermod -aG docker $USER
```

**Verify Installation:**
```bash
docker --version
docker run hello-world
```

#### 2. Git Installation
Git is needed to clone the repository and manage version control.


#### 3. Node.js Installation (for Local Development)
Node.js is required for local development and testing of the application.

#### 4. AWS CLI Installation (for Terraform Deployment)
AWS CLI is required for managing AWS resources and Terraform state.


#### 5. Terraform Installation
Terraform is used for Infrastructure as Code to provision AWS resources.

### Pre-Setup Verification

Before proceeding with the setup, run these commands to ensure everything is properly installed:

```bash
# Check all required tools
echo "=== System Check ==="
echo "Docker: $(docker --version)"
echo "Git: $(git --version)"
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "AWS CLI: $(aws --version)"
echo "Terraform: $(terraform --version)"


## 📖 Detailed Setup Instructions

This section provides comprehensive step-by-step instructions with explanations, troubleshooting tips, and best practices for each component.

### Part I: Kubernetes Environment Setup

#### Step 1: Cluster Setup and Verification

The cluster setup process creates a local Kubernetes environment using kind (Kubernetes in Docker). This approach allows you to run a full Kubernetes cluster on your local machine without requiring cloud resources.

```bash
# Run the automated cluster setup
./k8s/setup-cluster.sh
```

**What the setup script does:**

1. **Prerequisites Check**: Verifies Docker is running and has sufficient resources
2. **Tool Installation**: Installs kubectl and kind if not already present
3. **Cluster Creation**: Creates a 3-node cluster (1 control plane + 2 worker nodes)
4. **Configuration**: Sets up port mappings for ingress access
5. **Verification**: Ensures all nodes are ready and healthy

**Expected Output:**
```
✅ Docker is running
✅ kubectl is installed
✅ kind is installed
✅ Creating Kubernetes cluster...
✅ Cluster 'devops-cluster' created successfully
✅ All nodes are ready
✅ Cluster setup completed successfully!
```


**Verify Cluster Status:**
```bash
# Check cluster information
kubectl cluster-info

# List all nodes
kubectl get nodes

# Check node details
kubectl describe nodes
```

#### Step 2: Application Building and Deployment

This step builds the Docker image and deploys it to the Kubernetes cluster along with all necessary supporting resources.

```bash
# Navigate to the application directory
cd app

# Build the Docker image
# This uses a multi-stage build for security and size optimization
docker build -t hello-world-app:latest .

# Verify the image was created
docker images | grep hello-world-app

# Load the image into the kind cluster
# This step is necessary because kind doesn't pull from external registries
kind load docker-image hello-world-app:latest --name devops-cluster

# Navigate to the Kubernetes configuration directory
cd ../k8s

# Deploy all Kubernetes resources
./deploy.sh
```

**What the deployment script does:**

1. **Namespace Creation**: Creates dedicated namespaces for the application and monitoring
2. **RBAC Setup**: Configures service accounts and permissions
3. **Secrets Management**: Creates Kubernetes secrets for sensitive data
4. **Application Deployment**: Deploys the Node.js application with 3 replicas
5. **Service Configuration**: Sets up internal and external services
6. **Ingress Setup**: Configures NGINX ingress for external access
7. **Monitoring Deployment**: Deploys Prometheus and Grafana
8. **Network Policies**: Applies security policies for pod communication

**Expected Deployment Output:**
```
✅ Namespaces created
✅ RBAC configured
✅ Secrets created
✅ Application deployed
✅ Services configured
✅ Ingress configured
✅ Monitoring deployed
✅ Network policies applied
✅ Deployment completed successfully!
```

**Verify Deployment:**
```bash
# Check all pods across all namespaces
kubectl get pods -A

# Check application-specific resources
kubectl get all -n hello-world-app

# Check monitoring resources
kubectl get all -n monitoring

# Check ingress configuration
kubectl get ingress -A
```

#### Step 3: Application Verification and Testing

This step ensures that all components are working correctly and the application is accessible.

```bash
# Check application pod status
kubectl get pods -n hello-world-app

# Check application logs
kubectl logs -n hello-world-app deployment/hello-world-app

# Check service endpoints
kubectl get endpoints -n hello-world-app

# Test internal service access
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -qO- http://hello-world-app-service:3000
```

**Expected Pod Status:**
```
NAME                              READY   STATUS    RESTARTS   AGE
hello-world-app-6d4cf56db-abc12   1/1     Running   0          2m
hello-world-app-6d4cf56db-def34   1/1     Running   0          2m
hello-world-app-6d4cf56db-ghi56   1/1     Running   0          2m
```

**Test External Access:**
```bash
# Add hostname to hosts file (if not already done)
echo "127.0.0.1 hello-world.local" | sudo tee -a /etc/hosts

# Test application access
curl -v http://hello-world.local

# Test application metrics endpoint
curl http://hello-world.local/metrics

# Test health check endpoint
curl http://hello-world.local/health
```

#### Step 4: Monitoring and Observability Setup

This step sets up access to the monitoring tools and verifies they're working correctly.

```bash
# Check monitoring pods
kubectl get pods -n monitoring

# Access Prometheus (in a separate terminal)
kubectl port-forward -n monitoring svc/prometheus-service 9090:9090

# Access Grafana (in another terminal)
kubectl port-forward -n monitoring svc/grafana-service 3000:3000
```

**Access URLs and Credentials:**

- **Prometheus**: http://localhost:9090
  - No authentication required
  - Check "Status" → "Targets" to see all monitored endpoints

- **Grafana**: http://localhost:3000
  - Username: `admin`
  - Password: `admin123`
  - Default dashboards are pre-configured

**Verify Monitoring:**
```bash
# Check Prometheus targets
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health}'


```

### Part II: AWS Infrastructure Setup

This section covers setting up the AWS infrastructure using Terraform. This is optional and can be done independently of the Kubernetes setup.

#### Step 1: AWS Account and Credentials Setup

Before deploying to AWS, you need to configure your AWS credentials and create the necessary resources for Terraform state management.

```bash
# Configure AWS credentials
# You'll need your AWS Access Key ID and Secret Access Key
aws configure

# Enter your credentials when prompted:
# AWS Access Key ID: [Your Access Key]
# AWS Secret Access Key: [Your Secret Key]
# Default region name: [Your preferred region, e.g., us-east-1]
# Default output format: json
```

**Create S3 Bucket for Terraform State:**
```bash
# Create a unique S3 bucket name (replace with your preferred name)
BUCKET_NAME="devops-assessment-terraform-state-$(date +%s)"

# Create the S3 bucket
aws s3 mb s3://$BUCKET_NAME

# Enable versioning for state file backup
aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled

# Enable server-side encryption
aws s3api put-bucket-encryption --bucket $BUCKET_NAME --server-side-encryption-configuration '{
    "Rules": [
        {
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }
    ]
}'
```

**Create DynamoDB Table for State Locking:**
```bash
# Create DynamoDB table for state locking
aws dynamodb create-table \
    --table-name terraform-state-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region $(aws configure get region)
```

**Update Terraform Backend Configuration:**
```bash
# Navigate to terraform directory
cd terraform

# Update the backend.tf file with your S3 bucket name
# Replace 'your-bucket-name' with the actual bucket name you created
sed -i "s/your-bucket-name/$BUCKET_NAME/g" backend.tf
```

#### Step 2: SSH Key Pair Setup

You'll need an SSH key pair to access the EC2 instances.

```bash
# Generate a new SSH key pair (if you don't have one)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/devops-assessment-key -N ""

# Import the public key to AWS
aws ec2 import-key-pair \
    --key-name devops-assessment-key \
    --public-key-material fileb://~/.ssh/devops-assessment-key.pub

# Set proper permissions for the private key
chmod 600 ~/.ssh/devops-assessment-key
```

#### Step 3: Terraform Deployment

Now you can deploy the AWS infrastructure using Terraform.

```bash
# Navigate to terraform directory
cd terraform

# Initialize Terraform with the backend configuration
terraform init

# Validate the Terraform configuration
terraform validate

# Plan the deployment to see what will be created
terraform plan -var="key_name=devops-assessment-key"

# Apply the configuration to create the infrastructure
terraform apply -var="key_name=devops-assessment-key"

# When prompted, type 'yes' to confirm the deployment
```

**What Terraform Creates:**

1. **VPC Network Module**:
   - VPC with custom CIDR block
   - 3 public subnets across different availability zones
   - 3 private subnets across different availability zones
   - Internet Gateway for public subnet access
   - NAT Gateway for private subnet internet access
   - Route tables and associations

2. **Servers Module**:
   - 2 public EC2 instances (bastion hosts)
   - 1 private EC2 instance
   - Security groups with least privilege access
   - CloudWatch monitoring integration

**Expected Output:**
```
Plan: 25 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

Apply complete! Resources: 25 added, 0 changed, 0 destroyed.

Outputs:

public_instance_ips = [
  "3.250.123.45",
  "3.250.123.46"
]
private_instance_ip = "10.0.2.100"
vpc_id = "vpc-12345678"
```

#### Step 4: Access and Verification

Once the infrastructure is deployed, you can access the EC2 instances.

```bash
# Get the output values
terraform output

# SSH to the first public instance (bastion host)
ssh -i ~/.ssh/devops-assessment-key ec2-user@$(terraform output -raw public_instance_ips | jq -r '.[0]')

# From the bastion host, SSH to the private instance
ssh -i ~/.ssh/devops-assessment-key ec2-user@$(terraform output -raw private_instance_ip)
```

**Verify Infrastructure:**
```bash
# Check VPC and subnets
aws ec2 describe-vpcs --vpc-ids $(terraform output -raw vpc_id)
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$(terraform output -raw vpc_id)"

# Check EC2 instances
aws ec2 describe-instances --filters "Name=vpc-id,Values=$(terraform output -raw vpc_id)" --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress,PrivateIpAddress]' --output table

# Check security groups
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$(terraform output -raw vpc_id)"
```

#### Step 5: Cleanup (When Done)

To avoid unnecessary AWS charges, clean up the infrastructure when you're finished.

```bash
# Destroy the infrastructure
terraform destroy -var="key_name=devops-assessment-key"

# When prompted, type 'yes' to confirm

# Delete the S3 bucket (after Terraform destroy completes)
aws s3 rb s3://$BUCKET_NAME --force

# Delete the DynamoDB table
aws dynamodb delete-table --table-name terraform-state-lock

# Delete the SSH key pair
aws ec2 delete-key-pair --key-name devops-assessment-key
```

## 🔒 Security Implementation

### Kubernetes Security Features

#### 1. RBAC (Role-Based Access Control)
- **Service Account**: `hello-world-app-sa` with minimal permissions
- **Role**: Limited to pod/service read access and log access
- **RoleBinding**: Binds service account to role

#### 2. Network Policies
- **Ingress Rules**: Allow traffic only from ingress-nginx and monitoring namespaces
- **Egress Rules**: Allow DNS resolution and HTTP/HTTPS outbound traffic
- **Pod Isolation**: Restricts pod-to-pod communication

#### 3. Secrets Management
- **Kubernetes Secrets**: Store API keys and database URLs
- **Base64 Encoding**: Proper encoding for sensitive data
- **Access Control**: Secrets accessible only to application pods

#### 4. Container Security
- **Non-root User**: Application runs as user ID 1001
- **Read-only Root Filesystem**: Enhanced security
- **Dropped Capabilities**: All Linux capabilities dropped
- **Resource Limits**: CPU and memory limits enforced

### AWS Security Features

#### 1. Network Security
- **VPC Isolation**: Private subnets with NAT Gateway
- **Security Groups**: CIDR-restricted SSH access
- **Bastion Host**: Secure access to private instances

#### 2. Instance Security
- **SSH Key Authentication**: Password authentication disabled
- **Root Login Disabled**: Enhanced SSH security
- **CloudWatch Monitoring**: System metrics and logs collection

#### 3. Infrastructure Security
- **Encrypted State**: Terraform state encrypted in S3
- **State Locking**: DynamoDB prevents concurrent modifications
- **IAM Roles**: Least privilege access for Terraform

### Vulnerability Scanning
- **Trivy Integration**: Automated vulnerability scanning in CI/CD
- **Image Scanning**: Docker image security analysis
- **Code Scanning**: Repository security analysis
- **SARIF Reports**: Integration with GitHub Security tab

## 📊 Monitoring & Observability

### Prometheus Configuration
- **Kubernetes Components**: API server, nodes, kubelets monitoring
- **Application Metrics**: Custom HTTP request metrics
- **Scrape Intervals**: 15s for system, 10s for application
- **Service Discovery**: Automatic pod discovery

### Grafana Dashboards
- **Kubernetes Cluster Dashboard**:
  - Node CPU usage
  - Node memory usage
  - System resource utilization
- **Application Dashboard**:
  - Request rate (requests/second)
  - Request duration (latency)
  - HTTP status code distribution

### Application Metrics
- **HTTP Request Duration**: Histogram with custom buckets
- **HTTP Request Count**: Counter with method/route/status labels
- **Default Metrics**: Node.js runtime metrics via prom-client

### Access URLs
- **Prometheus**: `http://localhost:9090` (port-forward required)
- **Grafana**: `http://localhost:3000` (admin/admin123)
- **Application Metrics**: `http://hello-world.local/metrics`

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

#### 1. Security Scanning
- **Trivy Vulnerability Scanner**: Code and image scanning
- **SARIF Integration**: Results uploaded to GitHub Security tab
- **Automated Scanning**: Runs on every push and PR

#### 2. Testing
- **Node.js Setup**: Automated Node.js environment
- **Dependency Installation**: Cached npm dependencies
- **Linting**: ESLint code quality checks
- **Unit Tests**: Automated test execution

#### 3. Build & Push
- **Docker Buildx**: Multi-platform image building
- **Image Tagging**: Semantic versioning and branch-based tags
- **Registry Push**: Automated Docker Hub push
- **Image Scanning**: Post-build security analysis

#### 4. Deployment
- **Kubernetes Deployment**: Automated kubectl deployment
- **Rollout Verification**: Health check and status verification
- **Rollback Mechanism**: Automatic rollback on failure

### Pipeline Features
- **Idempotent Operations**: Safe to re-run
- **Environment Protection**: Production environment gates
- **Secret Management**: Secure credential handling
- **Parallel Execution**: Optimized job dependencies

## 🏗️ Infrastructure as Code

### Terraform Modules

#### VPC Network Module (`modules/vpc-network`)
**Features:**
- 1 VPC with configurable CIDR
- 3 Public subnets across multiple AZs
- 3 Private subnets across multiple AZs
- Internet Gateway for public access
- NAT Gateway for private subnet internet access
- Route tables and associations

**Inputs:**
- `vpc_cidr`: VPC CIDR block
- `availability_zones`: List of AZs
- `public_subnets`: Public subnet CIDRs
- `private_subnets`: Private subnet CIDRs

#### Servers Module (`modules/servers`)
**Features:**
- 2 Public EC2 instances (bastion hosts)
- 1 Private EC2 instance
- Security groups with least privilege
- Bastion host setup for private access
- CloudWatch monitoring integration

**Inputs:**
- `vpc_id`: VPC ID
- `subnet_ids`: Subnet IDs
- `key_name`: SSH key pair name
- `instance_type`: EC2 instance type

### Remote State Management
- **S3 Backend**: Encrypted state storage
- **DynamoDB Locking**: State locking to prevent conflicts
- **Versioning**: State file versioning enabled
- **Encryption**: Server-side encryption for state files

### Best Practices
- **Modular Design**: Reusable, maintainable modules
- **Variable Validation**: Input validation and defaults
- **Tagging Strategy**: Consistent resource tagging
- **Output Documentation**: Clear output descriptions


### Performance Optimization
- **Resource Limits**: Adjust CPU/memory limits based on usage
- **Replica Scaling**: Scale application replicas as needed
- **Storage Optimization**: Monitor PVC usage and cleanup
- **Network Policies**: Review and adjust as needed

### Security Hardening
- **Secret Rotation**: Regularly rotate Kubernetes secrets
- **Image Updates**: Keep base images updated
- **Access Reviews**: Regular RBAC access reviews
- **Network Policies**: Continuous network policy refinement

## 📝 Additional Notes

### Production Considerations
- **High Availability**: Multi-AZ deployment
- **Backup Strategy**: Regular state and data backups
- **Monitoring**: Enhanced monitoring and alerting
- **Security**: Additional security layers and compliance



