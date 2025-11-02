#!/bin/bash
set -e

echo "=== Security Hardening ==="

# Enable automatic security updates
sudo apt-get install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades

# Configure unattended-upgrades
sudo tee /etc/apt/apt.conf.d/50unattended-upgrades > /dev/null <<EOF
Unattended-Upgrade::Allowed-Origins {
    "\${distro_id}:\${distro_codename}";
    "\${distro_id}:\${distro_codename}-security";
    "\${distro_id}ESMApps:\${distro_codename}-apps-security";
    "\${distro_id}ESM:\${distro_codename}-infra-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
EOF

# SSH hardening
echo "Configuring SSH security..."
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config

# Add SSH hardening directives
sudo tee -a /etc/ssh/sshd_config > /dev/null <<EOF

# Security hardening
Protocol 2
StrictModes yes
MaxAuthTries 3
MaxSessions 2
ClientAliveInterval 300
ClientAliveCountMax 2
PermitEmptyPasswords no
IgnoreRhosts yes
HostbasedAuthentication no
EOF

# Configure firewall (UFW)
echo "Configuring firewall..."
sudo apt-get install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp comment 'SSH'
sudo ufw --force enable

# Disable unnecessary services
echo "Disabling unnecessary services..."
sudo systemctl disable systemd-resolved || true

# Kernel hardening via sysctl
echo "Applying kernel hardening..."
sudo tee /etc/sysctl.d/99-security-hardening.conf > /dev/null <<EOF
# IP Forwarding
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# Syn flood protection
net.ipv4.tcp_syncookies = 1

# Ignore ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0

# Ignore source-routed packets
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0

# Log martian packets
net.ipv4.conf.all.log_martians = 1

# Ignore ICMP ping requests
net.ipv4.icmp_echo_ignore_all = 0

# Protect against tcp time-wait assassination hazards
net.ipv4.tcp_rfc1337 = 1

# Enable source validation by reversed path
net.ipv4.conf.all.rp_filter = 1

# Disable IPv6 (if not needed)
net.ipv6.conf.all.disable_ipv6 = 0
EOF

sudo sysctl -p /etc/sysctl.d/99-security-hardening.conf

# Set secure permissions
echo "Setting secure file permissions..."
sudo chmod 644 /etc/passwd
sudo chmod 600 /etc/shadow
sudo chmod 644 /etc/group
sudo chmod 600 /boot/grub/grub.cfg || true

# Install and configure fail2ban
echo "Installing fail2ban..."
sudo apt-get install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Create fail2ban local config
sudo tee /etc/fail2ban/jail.local > /dev/null <<EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = 22
logpath = /var/log/auth.log
EOF

sudo systemctl restart fail2ban

# Install ClamAV (antivirus)
echo "Installing ClamAV..."
sudo apt-get install -y clamav clamav-daemon
sudo systemctl stop clamav-freshclam || true
sudo freshclam
sudo systemctl start clamav-freshclam

# Install aide (intrusion detection)
echo "Installing AIDE..."
sudo apt-get install -y aide
sudo aideinit

echo "✅ Security hardening complete"
