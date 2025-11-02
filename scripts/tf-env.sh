#!/usr/bin/env bash
# Terraform environment management script
# Usage: ./scripts/tf-env.sh <environment> <command>
# Example: ./scripts/tf-env.sh dev plan

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TF_DIR="$PROJECT_ROOT/terraform/aws-ec2"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function usage() {
    cat <<EOF
Usage: $0 <environment> <command> [terraform-args]

Environments:
  dev       - Development environment (t2.micro, 1 instance)
  staging   - Staging environment (t3.small, 2 instances)
  prod      - Production environment (t3.medium, 3 instances)

Commands:
  init      - Initialize Terraform for environment
  plan      - Show execution plan
  apply     - Apply changes
  destroy   - Destroy infrastructure (requires confirmation)
  validate  - Validate Terraform configuration
  fmt       - Format Terraform files
  output    - Show outputs
  state     - Run terraform state commands

Examples:
  $0 dev plan
  $0 staging apply
  $0 prod output
  $0 dev destroy

EOF
    exit 1
}

# Check arguments
if [ $# -lt 2 ]; then
    usage
fi

ENV=$1
CMD=$2
shift 2

# Validate environment
if [[ ! "$ENV" =~ ^(dev|staging|prod)$ ]]; then
    echo -e "${RED}Error: Invalid environment '$ENV'${NC}"
    echo "Valid environments: dev, staging, prod"
    exit 1
fi

TFVARS_FILE="$TF_DIR/environments/${ENV}.tfvars"
WORKSPACE="$ENV"

# Check if tfvars file exists
if [ ! -f "$TFVARS_FILE" ]; then
    echo -e "${RED}Error: Environment file not found: $TFVARS_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}==> Environment: $ENV${NC}"
echo -e "${GREEN}==> Using vars file: $TFVARS_FILE${NC}"

cd "$TF_DIR"

# Initialize if needed
if [ ! -d ".terraform" ]; then
    echo -e "${YELLOW}Terraform not initialized. Running init...${NC}"
    terraform init
fi

# Select or create workspace
terraform workspace select "$WORKSPACE" 2>/dev/null || terraform workspace new "$WORKSPACE"

echo -e "${GREEN}==> Workspace: $(terraform workspace show)${NC}"

# Execute command
case "$CMD" in
    init)
        terraform init "$@"
        ;;
    plan)
        terraform plan -var-file="$TFVARS_FILE" "$@"
        ;;
    apply)
        echo -e "${YELLOW}About to apply changes to ${ENV} environment${NC}"
        read -p "Are you sure? (yes/no): " confirm
        if [ "$confirm" == "yes" ]; then
            terraform apply -var-file="$TFVARS_FILE" "$@"
        else
            echo "Aborted"
            exit 1
        fi
        ;;
    destroy)
        echo -e "${RED}WARNING: About to DESTROY ${ENV} environment!${NC}"
        read -p "Type '$ENV' to confirm: " confirm
        if [ "$confirm" == "$ENV" ]; then
            terraform destroy -var-file="$TFVARS_FILE" "$@"
        else
            echo "Aborted"
            exit 1
        fi
        ;;
    validate)
        terraform validate
        ;;
    fmt)
        terraform fmt -recursive
        ;;
    output)
        terraform output "$@"
        ;;
    state)
        terraform state "$@"
        ;;
    *)
        echo -e "${RED}Unknown command: $CMD${NC}"
        usage
        ;;
esac
