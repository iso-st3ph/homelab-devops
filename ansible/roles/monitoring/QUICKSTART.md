# Monitoring Role Quick Start

## Deploy Node Exporter to Remote Hosts

This role installs Prometheus Node Exporter as a systemd service on your infrastructure.

### Prerequisites

1. Ansible installed on control machine
2. SSH access to target hosts
3. Sudo privileges on target hosts

### Step 1: Update your inventory

Edit `ansible/inventories/hosts` to include your target hosts:

```ini
[monitoring]
server1.local ansible_host=192.168.1.10
server2.local ansible_host=192.168.1.11
server3.local ansible_host=192.168.1.12

[all:vars]
ansible_user=your_user
ansible_become=true
```

### Step 2: Deploy Node Exporter

```bash
# Deploy to all hosts
cd ~/Github/homelab-devops
ansible-playbook -i ansible/inventories/hosts ansible/playbooks/deploy-monitoring.yml

# Deploy to specific group
ansible-playbook -i ansible/inventories/hosts ansible/playbooks/deploy-monitoring.yml --limit monitoring

# Check without making changes
ansible-playbook -i ansible/inventories/hosts ansible/playbooks/deploy-monitoring.yml --check
```

### Step 3: Verify Installation

```bash
# Check service status on all hosts
ansible all -i ansible/inventories/hosts -m systemd -a "name=node_exporter" --become

# Test metrics endpoint
ansible all -i ansible/inventories/hosts -m uri -a "url=http://localhost:9100/metrics status_code=200"
```

### Step 4: Update Prometheus Configuration

#### Option A: Manual Configuration

Edit `docker/monitoring-stack/prometheus/prometheus.yml`:

```yaml
scrape_configs:
  - job_name: node_exporter_homelab
    static_configs:
      - targets:
          - '192.168.1.10:9100'
          - '192.168.1.11:9100'
          - '192.168.1.12:9100'
        labels:
          environment: 'homelab'
```

Reload Prometheus:
```bash
make mon-up
docker compose -f docker/monitoring-stack/docker-compose.yml restart prometheus
```

#### Option B: Auto-generate Configuration

Use the provided script:

```bash
# Generate Prometheus targets from inventory
python3 scripts/generate_prometheus_targets.py ansible/inventories/hosts > /tmp/targets.yml

# Review the output
cat /tmp/targets.yml

# Manually add to prometheus.yml scrape_configs section
```

### Step 5: View Metrics in Grafana

1. Start monitoring stack: `make mon-up`
2. Open Grafana: http://localhost:3001
3. Import dashboard ID **1860** (Node Exporter Full)
4. View metrics from all your hosts!

## Customization

Override default variables in your playbook:

```yaml
---
- name: Deploy Node Exporter with custom config
  hosts: monitoring
  become: true
  
  roles:
    - role: monitoring
      vars:
        node_exporter_version: "1.8.2"
        node_exporter_port: 9100
        node_exporter_firewall_enable: true
```

## Troubleshooting

**Service not starting:**
```bash
ansible all -m shell -a "systemctl status node_exporter" --become
ansible all -m shell -a "journalctl -u node_exporter -n 50" --become
```

**Firewall blocking access:**
```bash
# Fedora/RHEL
ansible all -m shell -a "firewall-cmd --list-ports" --become

# Ubuntu/Debian
ansible all -m shell -a "ufw status" --become
```

**Test from Prometheus host:**
```bash
# From your workstation
curl http://192.168.1.10:9100/metrics
```

## Architecture

```
┌─────────────────┐
│   Prometheus    │
│  (Container)    │
└────────┬────────┘
         │ scrapes metrics
         ├─────────────────────────────────┐
         │                                 │
         ▼                                 ▼
┌──────────────────┐            ┌──────────────────┐
│  Node Exporter   │            │  Node Exporter   │
│   Host Server 1  │            │   Host Server 2  │
│    :9100         │            │    :9100         │
└──────────────────┘            └──────────────────┘
```

## Security Notes

- Node Exporter runs as unprivileged user
- Systemd hardening enabled
- Only exposes metrics port (9100)
- No write access to system
- Consider restricting access via firewall rules

For more details, see `ansible/roles/monitoring/README.md`
