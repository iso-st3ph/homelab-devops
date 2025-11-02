#!/bin/bash
set -e

echo "=== Installing Base Packages ==="

# Essential tools
sudo apt-get install -y \
  curl \
  wget \
  git \
  vim \
  htop \
  net-tools \
  iptables \
  ca-certificates \
  gnupg \
  lsb-release \
  software-properties-common \
  apt-transport-https \
  unzip \
  jq \
  python3 \
  python3-pip \
  build-essential

# AWS CLI v2
echo "Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

# AWS SSM Agent (should be pre-installed on Ubuntu AMIs)
sudo snap install amazon-ssm-agent --classic || true

# CloudWatch Agent
echo "Installing CloudWatch Agent..."
wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
rm -f amazon-cloudwatch-agent.deb

echo "✅ Base packages installed"
