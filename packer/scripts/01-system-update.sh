#!/bin/bash
set -e

echo "=== System Update ==="

# Update package lists
sudo apt-get update -y

# Upgrade all packages
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Dist upgrade
sudo DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y

# Clean up
sudo apt-get autoremove -y
sudo apt-get autoclean -y

echo "✅ System update complete"
