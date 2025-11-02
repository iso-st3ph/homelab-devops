#!/usr/bin/env python3
"""
Generate Prometheus scrape configuration from Ansible inventory.
This script reads the Ansible inventory and outputs a Prometheus-compatible
YAML configuration for node_exporter targets.
"""

import sys
import yaml
import subprocess
import json


def get_ansible_inventory(inventory_path):
    """Get inventory data using ansible-inventory command."""
    try:
        result = subprocess.run(
            ['ansible-inventory', '-i', inventory_path, '--list'],
            capture_output=True,
            text=True,
            check=True
        )
        return json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error running ansible-inventory: {e}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error parsing inventory JSON: {e}", file=sys.stderr)
        sys.exit(1)


def generate_prometheus_config(inventory_data, port=9100):
    """Generate Prometheus scrape config from inventory."""
    targets = []
    
    # Extract all hosts from inventory
    all_hosts = inventory_data.get('_meta', {}).get('hostvars', {})
    
    for hostname, host_vars in all_hosts.items():
        # Skip localhost/local connections
        if hostname in ['localhost', '127.0.0.1']:
            continue
            
        # Get ansible_host or use hostname
        host_ip = host_vars.get('ansible_host', hostname)
        target = f"{host_ip}:{port}"
        
        targets.append({
            'targets': [target],
            'labels': {
                'instance': hostname,
                'environment': 'homelab'
            }
        })
    
    scrape_config = {
        'job_name': 'node_exporter_homelab',
        'static_configs': targets
    }
    
    return scrape_config


def main():
    if len(sys.argv) < 2:
        print("Usage: generate_prometheus_targets.py <inventory_file> [port]")
        print("Example: generate_prometheus_targets.py ansible/inventories/hosts 9100")
        sys.exit(1)
    
    inventory_path = sys.argv[1]
    port = int(sys.argv[2]) if len(sys.argv) > 2 else 9100
    
    print("# Generated Prometheus scrape configuration", file=sys.stderr)
    print(f"# From inventory: {inventory_path}", file=sys.stderr)
    print(f"# Node Exporter port: {port}", file=sys.stderr)
    print("#", file=sys.stderr)
    
    inventory = get_ansible_inventory(inventory_path)
    config = generate_prometheus_config(inventory, port)
    
    # Output YAML
    output = yaml.dump([config], default_flow_style=False, sort_keys=False)
    print(output)
    
    print("\n# Add this to your docker/monitoring-stack/prometheus/prometheus.yml", file=sys.stderr)
    print("# under the 'scrape_configs:' section", file=sys.stderr)


if __name__ == '__main__':
    main()
