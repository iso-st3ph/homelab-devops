#!/bin/bash
set -e

echo "=== Cleanup ==="

# Clear package cache
sudo apt-get clean
sudo apt-get autoclean
sudo apt-get autoremove -y

# Clear bash history
cat /dev/null > ~/.bash_history
history -c

# Remove SSH host keys (will be regenerated on first boot)
sudo rm -f /etc/ssh/ssh_host_*

# Clear cloud-init logs
sudo cloud-init clean --logs --seed

# Clear log files
sudo find /var/log -type f -exec truncate -s 0 {} \;

# Remove temporary files
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

# Clear machine-id
sudo truncate -s 0 /etc/machine-id

# Sync filesystem
sync

echo "✅ Cleanup complete"
