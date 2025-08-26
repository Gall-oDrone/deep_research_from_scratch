# EKS Workshop IDE - Terraform Infrastructure

This Terraform configuration creates a complete IDE environment for EKS workshops, replicating the functionality of the CloudFormation template while following AWS EKS best practices.

## Architecture Overview

The infrastructure includes:

- **VPC and Networking**: Custom VPC with public subnets, internet gateway, and route tables
- **Security Groups**: Enhanced security groups with Jupyter Notebook support
- **IAM Roles and Policies**: Comprehensive IAM setup for IDE functionality
- **EC2 Instance**: Amazon Linux 2023 instance with code-server and Jupyter
- **CloudFront Distribution**: CDN for secure access to the IDE
- **Secrets Manager**: Secure password storage for IDE access
- **Lambda Function**: Bootstrap automation for the IDE instance
- **SSM Documents**: Systems Manager documents for instance configuration

## Features

### Enhanced Jupyter Notebook Support
- Pre-installed Jupyter, JupyterLab, and data science packages
- Systemd service for automatic Jupyter startup
- Security group rules for Jupyter ports (8888, 8887)
- CloudFront cache behaviors for Jupyter paths
- Test notebook creation for verification

### Security Enhancements
- Encrypted EBS volumes
- IAM roles with least privilege access
- Secrets Manager for password management
- Enhanced security group rules
- CloudFront for secure access

### Best Practices Implementation
- Modular Terraform structure
- Comprehensive tagging strategy
- Resource naming conventions
- Error handling and retry logic
- Proper dependency management

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured
- Appropriate AWS permissions

## Quick Start

1. **Clone and navigate to the terraform directory**:
   ```bash
   cd terraform
   ```

2. **Copy and customize the variables file**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Plan the deployment**:
   ```bash
   terraform plan
   ```

5. **Deploy the infrastructure**:
   ```bash
   terraform apply
   ```

6. **Access the IDE**:
   - Get the CloudFront URL from the outputs
   - Use the password from Secrets Manager
   - Access Jupyter at `https://your-cloudfront-url/jupyter`

## Configuration

### Variables

Key variables you can customize:

- `aws_region`: AWS region for deployment
- `environment`: Environment name for resource tagging
- `instance_type`: EC2 instance type (default: t3.medium)
- `instance_volume_size`: Root volume size in GB (default: 30)
- `vpc_cidr`: VPC CIDR block (default: 10.0.0.0/24)

### Jupyter Notebook Access

The infrastructure includes enhanced Jupyter support:

- **Port 8888**: Standard Jupyter Notebook
- **Port 8887**: Jupyter Kernel Gateway
- **Security Groups**: Pre-configured rules for Jupyter access
- **CloudFront**: Cache behaviors for `/jupyter/*` paths
- **Auto-start**: Jupyter starts automatically with the instance

### Code-Server IDE

- **Port 8889**: Code-server IDE
- **Authentication**: Password-based (stored in Secrets Manager)
- **Extensions**: Pre-installed Python and data science extensions

## Module Structure

```
terraform/
├── main.tf                 # Main configuration
├── variables.tf            # Variable definitions
├── outputs.tf              # Output definitions
├── versions.tf             # Provider versions
├── terraform.tfvars.example # Example variables
├── README.md               # This file
└── modules/
    ├── vpc/                # VPC and networking
    ├── security_groups/    # Security group configuration
    ├── iam/                # IAM roles and policies
    ├── secrets/            # Secrets Manager
    ├── ec2/                # EC2 instance
    ├── cloudfront/         # CloudFront distribution
    ├── lambda/             # Lambda functions
    └── ssm/                # SSM documents
```

## Security Considerations

### Network Security
- VPC with public subnets only (for workshop purposes)
- Security groups with specific port access
- CloudFront for secure external access

### Access Control
- IAM roles with least privilege
- Secrets Manager for credential storage
- Password-based authentication for IDE

### Data Protection
- Encrypted EBS volumes
- Secure password generation
- No persistent sensitive data storage

## Monitoring and Logging

- CloudWatch Logs for Lambda functions
- SSM command execution logging
- EC2 instance logs via SSM

## Troubleshooting

### Common Issues

1. **Instance not accessible**:
   - Check security group rules
   - Verify CloudFront distribution status
   - Check SSM agent status

2. **Jupyter not starting**:
   - Check systemd service status: `sudo systemctl status jupyter`
   - Verify port 8888 is open in security groups
   - Check Jupyter configuration

3. **Code-server issues**:
   - Check service status: `sudo systemctl status code-server@ec2-user`
   - Verify password in Secrets Manager
   - Check configuration file permissions

### Useful Commands

```bash
# Check Jupyter status
sudo systemctl status jupyter

# Check code-server status
sudo systemctl status code-server@ec2-user

# View Jupyter logs
sudo journalctl -u jupyter -f

# View code-server logs
sudo journalctl -u code-server@ec2-user -f

# Access Jupyter directly
http://instance-ip:8888

# Access code-server directly
http://instance-ip:8889
```

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

**Warning**: This will delete all resources including the EC2 instance and any data stored on it.

## Contributing

When contributing to this Terraform configuration:

1. Follow the existing module structure
2. Add appropriate variables and outputs
3. Include comprehensive documentation
4. Test changes in a non-production environment
5. Update this README with any new features

## License

This project is licensed under the same terms as the parent project.

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review AWS EKS best practices documentation
3. Open an issue in the project repository
