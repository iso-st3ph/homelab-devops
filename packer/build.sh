#!/bin/bash

set -e

echo "🚀 Packer Image Build Script"
echo "=============================="

# Check if packer is installed
if ! command -v packer &> /dev/null; then
    echo "❌ Packer not found. Installing..."
    
    # Install Packer
    PACKER_VERSION="1.11.2"
    wget -q https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip
    unzip -q packer_${PACKER_VERSION}_linux_amd64.zip
    sudo mv packer /usr/local/bin/
    rm -f packer_${PACKER_VERSION}_linux_amd64.zip
    
    echo "✅ Packer ${PACKER_VERSION} installed"
fi

packer version

# Initialize Packer plugins
echo ""
echo "📦 Initializing Packer plugins..."
packer init aws-ubuntu.pkr.hcl

# Validate template
echo ""
echo "🔍 Validating Packer template..."
packer validate -var-file=variables.pkrvars.hcl.example aws-ubuntu.pkr.hcl

echo ""
echo "✅ Validation successful!"
echo ""
echo "📋 To build the AMI, run:"
echo "   packer build -var-file=variables.auto.pkrvars.hcl aws-ubuntu.pkr.hcl"
echo ""
echo "💡 Make sure you have:"
echo "   - AWS credentials configured (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)"
echo "   - Or AWS CLI profile configured"
echo "   - Copied variables.pkrvars.hcl.example to variables.auto.pkrvars.hcl"
