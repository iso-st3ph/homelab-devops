# Monitoring Stack

Prometheus + Grafana + Node Exporter + cAdvisor monitoring stack for homelab infrastructure.

## Quick Start

1. **Set up environment variables:**
   ```bash
   cd docker/monitoring-stack
   cp .env.example .env
   nano .env  # Set a strong password for GF_SECURITY_ADMIN_PASSWORD
   ```

2. **Start the stack:**
   ```bash
   # From repo root
   make mon-up
   
   # Or from this directory
   docker compose up -d
   ```

3. **Access the services:**
   - **Grafana**: http://localhost:3000 (default: admin / changeme-please)
   - **Prometheus**: http://localhost:9090
   - **Node Exporter metrics**: http://localhost:9100/metrics
   - **cAdvisor**: http://localhost:8080

## Services

### Prometheus
- Scrapes metrics from all exporters every 15 seconds
- Retains data for 15 days
- Configuration: `prometheus/prometheus.yml`

### Grafana
- Pre-configured with Prometheus datasource
- Auto-provisions dashboards from `grafana/provisioning/dashboards/`
- Dark theme by default

### Node Exporter
- Exports host system metrics (CPU, memory, disk, network)
- Runs in host network mode for accurate metrics

### cAdvisor
- Monitors Docker container metrics
- Provides resource usage and performance data

## Adding Dashboards

Download JSON dashboards and place them in `grafana/provisioning/dashboards/`:

**Recommended dashboards:**
- Node Exporter Full (ID: 1860)
- Docker Container & Host Metrics (ID: 179)
- cAdvisor (ID: 893)

Import from Grafana.com:
```bash
# Example: Download dashboard 1860
curl -o grafana/provisioning/dashboards/node-exporter-full.json \
  https://grafana.com/api/dashboards/1860/revisions/latest/download
```

Restart Grafana to load new dashboards:
```bash
docker compose restart grafana
```

## Firewall Configuration (Fedora/RHEL)

If you need to access the services from other machines:

```bash
sudo firewall-cmd --add-port=3000/tcp --add-port=9090/tcp --add-port=8080/tcp --permanent
sudo firewall-cmd --reload
```

## Makefile Targets

From the repo root:

- `make mon-up` - Start the monitoring stack
- `make mon-down` - Stop the monitoring stack
- `make mon-logs` - View stack logs

## SELinux Notes

The compose file uses read-only binds and named volumes, so no special SELinux context is needed. If you later bind local directories for data persistence, append `:z` to volume mounts.

## Architecture

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Grafana   │────▶│  Prometheus  │◀────│Node Exporter│
│  :3000      │     │   :9090      │     │   :9100     │
└─────────────┘     └──────────────┘     └─────────────┘
                           ▲
                           │
                           │
                    ┌──────────────┐
                    │   cAdvisor   │
                    │    :8080     │
                    └──────────────┘
```

## Troubleshooting

**View logs:**
```bash
make mon-logs
# Or
docker compose logs -f [service-name]
```

**Restart a service:**
```bash
docker compose restart grafana
```

**Check Prometheus targets:**
Visit http://localhost:9090/targets to verify all scrape targets are healthy.

**Reset everything:**
```bash
make mon-down
docker volume rm monitoring-stack_prometheus_data monitoring-stack_grafana_data
make mon-up
```
