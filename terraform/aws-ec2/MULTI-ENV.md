# Multi-Environment Terraform Management

This directory demonstrates production-grade multi-environment infrastructure management with Terraform.

## Architecture

```
terraform/aws-ec2/
├── main.tf                    # Core infrastructure
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── versions.tf                # Provider versions
├── environments/              # Environment-specific configurations
│   ├── dev.tfvars            # Development: t2.micro, 1 instance
│   ├── staging.tfvars        # Staging: t3.small, 2 instances
│   └── prod.tfvars           # Production: t3.medium, 3 instances HA
└── README.md
```

## Environment Comparison

| Feature | Dev | Staging | Production |
|---------|-----|---------|------------|
| **Instance Type** | t2.micro | t3.small | t3.medium |
| **Instance Count** | 1 | 2 | 3 (multi-AZ) |
| **Availability Zones** | 1 | 2 | 3 |
| **Detailed Monitoring** | ❌ | ✅ | ✅ |
| **Automated Backups** | ❌ | ✅ (7 days) | ✅ (30 days) |
| **Auto Scaling** | ❌ | ❌ | ✅ (2-5 instances) |
| **Encryption** | ❌ | ❌ | ✅ |
| **SSH Access** | Open (for demo) | VPN only | Bastion only |
| **Estimated Cost/mo** | ~$8 | ~$30 | ~$90 |

## Quick Start

### Using Helper Script (Recommended)

```bash
# Initialize development environment
./scripts/tf-env.sh dev init

# Plan changes for development
./scripts/tf-env.sh dev plan

# Apply to development
./scripts/tf-env.sh dev apply

# View outputs
./scripts/tf-env.sh dev output

# Destroy development
./scripts/tf-env.sh dev destroy
```

### Manual Workflow

```bash
cd terraform/aws-ec2

# Initialize Terraform
terraform init

# Create/select workspace
terraform workspace new dev
# or
terraform workspace select dev

# Plan with environment-specific variables
terraform plan -var-file="environments/dev.tfvars"

# Apply
terraform apply -var-file="environments/dev.tfvars"
```

## Workspace Management

Terraform workspaces provide isolated state for each environment:

```bash
# List workspaces
terraform workspace list

# Create new workspace
terraform workspace new staging

# Switch workspace
terraform workspace select prod

# Show current workspace
terraform workspace show

# Delete workspace (must be empty)
terraform workspace delete dev
```

## Environment Variables

Each `.tfvars` file configures:

### Development (`dev.tfvars`)
- **Purpose**: Local testing, feature development
- **Cost**: Minimal (Free Tier eligible)
- **Security**: Relaxed (learning environment)
- **Uptime**: Can be stopped/started frequently

### Staging (`staging.tfvars`)
- **Purpose**: Pre-production testing, QA
- **Cost**: Moderate
- **Security**: Production-like
- **Uptime**: Business hours

### Production (`prod.tfvars`)
- **Purpose**: Live production workloads
- **Cost**: Optimized for reliability over cost
- **Security**: Hardened (encryption, monitoring, backups)
- **Uptime**: 24/7 with HA

## State Management

### Local State (Current Setup)

```
terraform.tfstate.d/
├── dev/
│   └── terraform.tfstate
├── staging/
│   └── terraform.tfstate
└── prod/
    └── terraform.tfstate
```

**⚠️ Warning**: Local state is for demo purposes only!

### Remote State (Production Recommended)

Update `versions.tf` for each environment:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "homelab-devops/${terraform.workspace}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
  }
}
```

**Benefits**:
- Team collaboration
- State locking (prevents concurrent modifications)
- State versioning/backup
- Encryption at rest

## Security Best Practices

### ✅ DO

- Use separate AWS accounts for dev/staging/prod
- Enable CloudTrail in all environments
- Use least-privilege IAM roles
- Encrypt state files (S3 with KMS)
- Enable MFA for production apply operations
- Use OIDC with GitHub Actions (no long-lived credentials)
- Tag all resources with environment, owner, cost center

### ❌ DON'T

- Commit `.tfvars` files with real credentials
- Use same SSH keys across all environments
- Allow production access from local machines
- Share IAM credentials across environments
- Disable logging/monitoring to save costs

## Cost Optimization

### Development
```bash
# Stop instances after work hours
aws ec2 stop-instances --instance-ids $(terraform output -raw instance_ids)

# Start instances when needed
aws ec2 start-instances --instance-ids $(terraform output -raw instance_ids)

# Or destroy completely
./scripts/tf-env.sh dev destroy
```

### Staging
```bash
# Use scheduled auto-scaling (scale down nights/weekends)
# Implement in main.tf:
resource "aws_autoscaling_schedule" "scale_down_evening" {
  scheduled_action_name  = "scale-down-evening"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = "0 19 * * MON-FRI"  # 7 PM weekdays
}
```

### Production
- Use Reserved Instances or Savings Plans for baseline capacity
- Use Spot Instances for auto-scaling beyond baseline
- Enable AWS Cost Anomaly Detection
- Set billing alerts

## CI/CD Integration

### GitHub Actions Workflow

```yaml
name: Terraform Multi-Environment

on:
  pull_request:
    paths:
      - 'terraform/**'
  push:
    branches:
      - main

jobs:
  terraform:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [dev, staging]  # Don't auto-deploy prod
    steps:
      - uses: actions/checkout@v3
      
      - uses: hashicorp/setup-terraform@v2
      
      - name: Terraform Init
        run: |
          cd terraform/aws-ec2
          terraform init
          terraform workspace select ${{ matrix.environment }} || terraform workspace new ${{ matrix.environment }}
      
      - name: Terraform Plan
        run: |
          cd terraform/aws-ec2
          terraform plan -var-file="environments/${{ matrix.environment }}.tfvars"
      
      - name: Terraform Apply (Auto for dev)
        if: github.ref == 'refs/heads/main' && matrix.environment == 'dev'
        run: |
          cd terraform/aws-ec2
          terraform apply -auto-approve -var-file="environments/${{ matrix.environment }}.tfvars"
```

## Promotion Workflow

### Dev → Staging → Prod

```bash
# 1. Develop and test in dev
./scripts/tf-env.sh dev apply

# 2. Test passes, promote to staging
./scripts/tf-env.sh staging plan
./scripts/tf-env.sh staging apply

# 3. Staging validated, promote to prod (manual approval)
./scripts/tf-env.sh prod plan > plan.txt
# Review plan.txt with team
./scripts/tf-env.sh prod apply
```

## Drift Detection

Detect manual changes outside Terraform:

```bash
# Run for each environment
for env in dev staging prod; do
  echo "==> Checking $env for drift"
  ./scripts/tf-env.sh $env plan -detailed-exitcode
done
```

Schedule in CI/CD to run daily and alert on drift.

## Disaster Recovery

### Backup State Files

```bash
# Automated backup script
#!/bin/bash
for env in dev staging prod; do
  terraform workspace select $env
  aws s3 cp terraform.tfstate \
    s3://backup-bucket/terraform-state/$env/$(date +%Y-%m-%d).tfstate
done
```

### Restore from Backup

```bash
# Restore specific environment
aws s3 cp s3://backup-bucket/terraform-state/prod/2024-01-15.tfstate \
  terraform.tfstate.d/prod/terraform.tfstate
```

## Troubleshooting

### Workspace Switching Issues

```bash
# If workspace selection fails
terraform workspace list
terraform workspace select dev

# If workspace is corrupted
rm -rf .terraform/
terraform init
terraform workspace new dev
```

### State Lock Issues

```bash
# Force unlock (use carefully!)
terraform force-unlock <LOCK_ID>

# View state
terraform show

# Pull state locally
terraform state pull > backup.tfstate
```

### Environment-Specific Debugging

```bash
# Set detailed logging
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform-debug.log

# Run command
./scripts/tf-env.sh dev plan
```

## Advanced Patterns

### Environment Inheritance

Create a `common.tfvars` for shared variables:

```hcl
# common.tfvars
project_name = "homelab-devops"
owner = "DevOps Team"
region = "us-east-1"
```

Then reference in environment files:

```bash
terraform plan \
  -var-file="common.tfvars" \
  -var-file="environments/dev.tfvars"
```

### Module Versioning

Pin module versions per environment:

```hcl
# dev - use latest
module "ec2" {
  source  = "./modules/ec2_minimal"
}

# prod - pin to tested version
module "ec2" {
  source  = "./modules/ec2_minimal"
  version = "1.2.3"
}
```

## Checklist Before Production

- [ ] Remote state backend configured (S3 + DynamoDB)
- [ ] State encryption enabled
- [ ] Separate AWS accounts per environment
- [ ] IAM roles with least privilege
- [ ] MFA required for production changes
- [ ] CloudTrail enabled
- [ ] Backups automated and tested
- [ ] Monitoring and alerting configured
- [ ] Runbooks documented
- [ ] Team trained on disaster recovery
- [ ] Cost alerts configured
- [ ] Compliance requirements met (SOC2, HIPAA, etc.)

## Next Steps

1. **Set up remote state backend**
   ```bash
   # Create S3 bucket and DynamoDB table
   aws s3 mb s3://my-terraform-state
   aws dynamodb create-table --table-name terraform-locks ...
   ```

2. **Implement policy-as-code**
   - Add Sentinel/OPA policies
   - Require tagging
   - Cost limits per environment

3. **Add more environments**
   - DR (disaster recovery)
   - Sandbox (testing new features)
   - Demo (customer demos)

4. **Automate promotion**
   - GitOps with ArgoCD/Flux
   - Automated testing between environments
   - Approval workflows

## References

- [Terraform Workspaces](https://developer.hashicorp.com/terraform/language/state/workspaces)
- [Managing Multiple Environments](https://developer.hashicorp.com/terraform/tutorials/modules/organize-configuration)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
