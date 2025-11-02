# Ansible Role: Monitoring (Node Exporter)

Installs and configures [Prometheus Node Exporter](https://github.com/prometheus/node_exporter) on Linux systems as a systemd service.

## Features

- ✅ Downloads and installs specific Node Exporter version
- ✅ Creates dedicated system user/group
- ✅ Systemd service with security hardening
- ✅ Automatic firewall configuration (firewalld/ufw)
- ✅ Idempotent installation (version checking)
- ✅ Health check verification

## Requirements

- Ansible 2.9+
- systemd-based Linux distribution (RHEL/Fedora/Ubuntu/Debian)
- Internet access to download Node Exporter binary

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yaml
# Node Exporter version to install
node_exporter_version: "1.8.2"
node_exporter_arch: "linux-amd64"

# Service configuration
node_exporter_port: 9100
node_exporter_web_listen_address: "0.0.0.0:9100"

# Firewall configuration
node_exporter_firewall_enable: true
node_exporter_firewall_zone: "public"
```

## Dependencies

None.

## Example Playbook

```yaml
---
- name: Deploy Node Exporter
  hosts: monitoring_targets
  become: true
  
  roles:
    - monitoring
```

With custom variables:

```yaml
---
- name: Deploy Node Exporter with custom config
  hosts: all
  become: true
  
  roles:
    - role: monitoring
      vars:
        node_exporter_version: "1.8.2"
        node_exporter_port: 9100
        node_exporter_firewall_enable: false
```

## Usage

### Deploy to all hosts

```bash
ansible-playbook -i ansible/inventories/hosts ansible/playbooks/deploy-monitoring.yml
```

### Deploy to specific host group

```bash
ansible-playbook -i ansible/inventories/hosts ansible/playbooks/deploy-monitoring.yml --limit webservers
```

### Verify installation

```bash
# Check service status
ansible all -i ansible/inventories/hosts -m systemd -a "name=node_exporter state=started" --become

# Test metrics endpoint
ansible all -i ansible/inventories/hosts -m uri -a "url=http://localhost:9100/metrics"
```

## Prometheus Configuration

After deploying Node Exporter to your hosts, add them to your Prometheus scrape configuration:

```yaml
scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets:
          - 'host1.example.com:9100'
          - 'host2.example.com:9100'
          - 'host3.example.com:9100'
        labels:
          environment: 'production'
```

Or use dynamic service discovery with file-based targets.

## Security Hardening

The systemd service includes security features:

- `NoNewPrivileges=true` - Prevents privilege escalation
- `ProtectHome=true` - Restricts access to /home directories
- `ProtectSystem=strict` - Makes /usr, /boot, /efi read-only
- `ProtectKernelTunables=true` - Protects kernel parameters
- `PrivateTmp=true` - Uses private /tmp directory

## Firewall Rules

The role automatically configures firewall rules:

- **RHEL/Fedora**: Uses `firewalld` to open port 9100/tcp
- **Ubuntu/Debian**: Uses `ufw` to allow port 9100/tcp

Set `node_exporter_firewall_enable: false` to disable automatic firewall configuration.

## License

MIT

## Author

iso-st3ph - Homelab DevOps Portfolio
