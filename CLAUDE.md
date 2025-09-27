# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Machine Learning Operations (MLOps) platform for Paytm's risk management system. The repository contains infrastructure as code and Kubernetes configurations for a cloud-native ML platform running on AWS.

## Architecture

### Infrastructure Components
- **Terraform Infrastructure**: Multi-environment setup with modules for AWS resources
  - VPC, EMR clusters, EKS, SageMaker, RDS, Route53, ALB
  - Environment-specific configurations in `terraform/environments/`
  - Reusable modules in `terraform/modules/`
- **Kubernetes Applications**: Helm charts for platform services
  - ArgoCD for GitOps deployment
  - Apache Superset for data visualization
  - AWS Load Balancer Controller, External Secrets, Ingress NGINX
  - Located in `k8s/infra-applications/`

### EMR Cluster Architecture
- **Dual-Cluster Pattern**: Each tenant has production (3-master HA) + staging (1-master) clusters
- **Memory-Optimized Fleets**: r6g/r6a/r5a instances (8 GiB RAM per vCPU) for big data workloads
- **Shared Infrastructure**: Clusters share Glue databases and S3 paths (no environment separation)
- **Cost Controls**: Separate budget limits ($1,500 production, $200 staging per tenant)
- **Autoscaling**: Aggressive memory-based scaling (15% threshold production, 25% staging)
- **Fleet Diversity**: 5-6 instance types per fleet for high spot availability

### Key Technologies
- **Infrastructure**: Terraform, AWS (EMR, EKS, SageMaker, S3, RDS)
- **Container Orchestration**: Kubernetes, Helm
- **Data Processing**: Apache Trino, Apache Iceberg
- **ML Platform**: AWS SageMaker
- **GitOps**: ArgoCD
- **Monitoring**: Superset, Prometheus (via servicemonitors)

## Common Development Tasks

### Terraform Operations
```bash
# Navigate to specific environment/module
cd terraform/environments/platform/00-infra-vpc/
terraform init
terraform plan
terraform apply
```

### AWS Profile Configuration
**IMPORTANT**: Always use the `pai-risk-mlops` profile for all AWS operations in this repository:
```bash
export AWS_PROFILE=pai-risk-mlops
# Or use --profile flag with AWS CLI commands
aws --profile pai-risk-mlops sts get-caller-identity
```

### Kubernetes/Helm Operations
```bash
# Install/upgrade applications with custom values
helm upgrade --install <app-name> <chart-path> -f <cluster-name>-values.yaml
```

## Important Conventions

### Terraform Structure
- **Environments**: `terraform/environments/` contains environment-specific configs
- **Modules**: `terraform/modules/` contains reusable infrastructure modules
- **State Management**: Each module has its own remote state configuration
- **Naming**: Resources follow pattern: `{product}-{tenant}-{environment}-{resource}`

### Kubernetes Structure  
- **Values Files**: Custom values named `{cluster-name}-values.yaml` (e.g., `pai-risk-mlops-platform-values.yaml`)
- **Templates**: Standard Helm template structure with helpers in `_helpers.tpl`
- **External Secrets**: Custom external secret templates for sensitive data management

### File Organization
- Infrastructure components are numbered (00, 01, 02, etc.) indicating deployment order
- Helm charts follow standard chart structure with custom value overrides
- All AWS resources include proper tagging and security configurations

## Tenant Management

### Provisioning New Tenants
Use the automated provisioning script for consistent tenant setup:
```bash
./scripts/provision-tenant.sh --tenant <name> --memory-optimized --staging
```

### Tenant Structure
Each tenant gets:
- Dedicated S3 buckets (artifacts + data)
- Shared Glue databases (iceberg + raw)
- Dual EMR clusters (production + staging)
- Budget controls and alerts
- CloudWatch monitoring

### Key Files
- `scripts/provision-tenant.sh` - Automated provisioning
- `NEW_TENANT.md` - Architecture documentation
- `terraform/environments/{tenant}/` - Tenant infrastructure

## SageMaker-EMR Integration

### Required IAM Permissions
The SageMaker execution role needs EMR access permissions. Add to the role policy:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticmapreduce:ListInstances",
        "elasticmapreduce:DescribeCluster",
        "elasticmapreduce:ListSteps",
        "elasticmapreduce:GetBlockPublicAccessConfiguration"
      ],
      "Resource": "arn:aws:elasticmapreduce:ap-south-1:880170353725:cluster/*"
    }
  ]
}
```

### Connecting from SageMaker Studio
```python
%load_ext sagemaker_studio_analytics_extension.magics
%sm_analytics emr connect --verify-certificate False --cluster-id <cluster-id> --auth-type None --language python
```

### Troubleshooting Connection Issues
1. **AccessDeniedException**: Update SageMaker execution role with EMR permissions
2. **Cluster Not Found**: Verify cluster ID and region
3. **Network Issues**: Check security groups allow SageMaker-EMR communication

## Known Limitations

### EMR Auto-Termination
The terraform EMR module doesn't support auto_termination_policy. For staging clusters requiring auto-termination, implement via:
- CloudWatch Events + Lambda
- EMR Step with shutdown action
- Manual idle timeout monitoring

## Terraform State Management

### Handling State Locks
**IMPORTANT**: Before forcing a Terraform unlock, investigate the reason for the stuck lock. This helps prevent recurrence and ensures you are not interrupting an active, legitimate operation.

Common causes of stuck locks:
- Previous terraform operation was interrupted (Ctrl+C, network issues)
- Multiple concurrent terraform operations
- CI/CD pipeline failures
- Crashed terraform process

To safely handle a stuck lock:
1. Check if anyone else is running terraform: `aws s3 ls s3://pai-risk-mlops-v1-foundation-tfstates/`
2. Verify no active terraform processes: `ps aux | grep terraform`
3. If safe to proceed, force unlock: `echo "yes" | terraform force-unlock <lock-id>`

## Security Considerations
- External Secrets Operator manages sensitive data
- IRSA (IAM Roles for Service Accounts) for secure AWS access
- Network policies and security groups properly configured
- S3 buckets have encryption and access controls enabled