#!/bin/bash

# EKS Workshop IDE - Terraform Deployment Script
# This script automates the deployment of the IDE infrastructure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform >= 1.0"
        exit 1
    fi
    
    # Check Terraform version
    TF_VERSION=$(terraform version -json | jq -r '.terraform_version')
    print_status "Terraform version: $TF_VERSION"
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install AWS CLI"
        exit 1
    fi
    
    # Check if AWS credentials are configured
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials are not configured. Please run 'aws configure'"
        exit 1
    fi
    
    # Check if jq is installed (for JSON parsing)
    if ! command -v jq &> /dev/null; then
        print_warning "jq is not installed. Some features may not work properly"
    fi
    
    print_success "Prerequisites check completed"
}

# Function to initialize Terraform
init_terraform() {
    print_status "Initializing Terraform..."
    
    if [ ! -f "terraform.tfvars" ]; then
        print_warning "terraform.tfvars not found. Creating from example..."
        if [ -f "terraform.tfvars.example" ]; then
            cp terraform.tfvars.example terraform.tfvars
            print_warning "Please edit terraform.tfvars with your configuration before continuing"
            read -p "Press Enter to continue after editing terraform.tfvars..."
        else
            print_error "terraform.tfvars.example not found"
            exit 1
        fi
    fi
    
    terraform init
    print_success "Terraform initialized"
}

# Function to plan Terraform deployment
plan_terraform() {
    print_status "Planning Terraform deployment..."
    
    terraform plan -out=tfplan
    print_success "Terraform plan completed"
}

# Function to apply Terraform deployment
apply_terraform() {
    print_status "Applying Terraform deployment..."
    
    if [ ! -f "tfplan" ]; then
        print_error "No plan file found. Run 'terraform plan' first"
        exit 1
    fi
    
    terraform apply tfplan
    print_success "Terraform deployment completed"
}

# Function to show outputs
show_outputs() {
    print_status "Retrieving deployment outputs..."
    
    echo ""
    echo "=== DEPLOYMENT OUTPUTS ==="
    terraform output
    echo ""
    
    # Get specific outputs
    IDE_URL=$(terraform output -raw ide_url 2>/dev/null || echo "Not available")
    PASSWORD_SECRET=$(terraform output -raw ide_password_secret_name 2>/dev/null || echo "Not available")
    INSTANCE_ID=$(terraform output -raw instance_id 2>/dev/null || echo "Not available")
    
    echo "=== ACCESS INFORMATION ==="
    echo "IDE URL: $IDE_URL"
    echo "Password Secret: $PASSWORD_SECRET"
    echo "Instance ID: $INSTANCE_ID"
    echo ""
    
    if [ "$PASSWORD_SECRET" != "Not available" ]; then
        print_status "To get the IDE password, run:"
        echo "aws secretsmanager get-secret-value --secret-id $PASSWORD_SECRET --query 'SecretString' --output text | jq -r '.password'"
    fi
    
    print_success "Deployment information displayed"
}

# Function to destroy infrastructure
destroy_infrastructure() {
    print_warning "This will destroy all infrastructure. Are you sure? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_status "Destroying infrastructure..."
        terraform destroy -auto-approve
        print_success "Infrastructure destroyed"
    else
        print_status "Destroy cancelled"
    fi
}

# Function to show help
show_help() {
    echo "EKS Workshop IDE - Terraform Deployment Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  deploy    - Deploy the infrastructure (init, plan, apply)"
    echo "  init      - Initialize Terraform"
    echo "  plan      - Plan the deployment"
    echo "  apply     - Apply the deployment"
    echo "  outputs   - Show deployment outputs"
    echo "  destroy   - Destroy the infrastructure"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 deploy     # Full deployment"
    echo "  $0 plan       # Only plan"
    echo "  $0 destroy    # Destroy infrastructure"
}

# Main script logic
case "${1:-deploy}" in
    "deploy")
        check_prerequisites
        init_terraform
        plan_terraform
        apply_terraform
        show_outputs
        ;;
    "init")
        check_prerequisites
        init_terraform
        ;;
    "plan")
        check_prerequisites
        init_terraform
        plan_terraform
        ;;
    "apply")
        check_prerequisites
        apply_terraform
        show_outputs
        ;;
    "outputs")
        show_outputs
        ;;
    "destroy")
        check_prerequisites
        destroy_infrastructure
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
