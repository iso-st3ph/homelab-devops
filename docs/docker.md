# Docker & Containerization

This homelab uses **Docker** and **Docker Compose** for containerized service orchestration.

---

## 🐳 Monitoring Stack

The primary Docker deployment is the **full observability stack** running in `docker/monitoring-stack/`:

### Services

| Service | Image | Port | Purpose |
|---------|-------|------|---------|
| **Prometheus** | `prom/prometheus:latest` | 9090 | Metrics collection & storage (15-day retention) |
| **Grafana** | `grafana/grafana:latest` | 3001 | Visualization & dashboards |
| **AlertManager** | `prom/alertmanager:latest` | 9093 | Alert routing & notification |
| **Loki** | `grafana/loki:latest` | 3100 | Log aggregation & storage (30-day retention) |
| **Promtail** | `grafana/promtail:latest` | - | Log collection from Docker containers |
| **Tempo** | `grafana/tempo:latest` | 3200 | Distributed tracing (30-day retention) |
| **Node Exporter** | `prom/node-exporter:latest` | 9100 | Host system metrics |
| **cAdvisor** | `gcr.io/cadvisor/cadvisor:latest` | 8080 | Container metrics |

### Quick Start

```bash
# Start the entire monitoring stack
make mon-up

# View logs
make mon-logs

# Stop the stack
make mon-down

# Restart a specific service
docker compose -f docker/monitoring-stack/docker-compose.yml restart grafana
```

### Access Points

- **Grafana**: [http://localhost:3001](http://localhost:3001) (admin / changeme-please)
- **Prometheus**: [http://localhost:9090](http://localhost:9090)
- **AlertManager**: [http://localhost:9093](http://localhost:9093)
- **Loki**: [http://localhost:3100](http://localhost:3100)
- **Tempo**: [http://localhost:3200](http://localhost:3200)
- **cAdvisor**: [http://localhost:8080](http://localhost:8080)

---

## 📁 Stack Structure

```
docker/monitoring-stack/
├── docker-compose.yml              # Service orchestration
├── prometheus/
│   ├── prometheus.yml              # Scrape configs
│   └── rules/                      # Alert rules
│       ├── node_alerts.yml
│       ├── container_alerts.yml
│       └── service_alerts.yml
├── alertmanager/
│   └── alertmanager.yml            # Slack integration
├── grafana/
│   └── provisioning/
│       ├── datasources/            # Auto-provisioned datasources
│       │   ├── prometheus.yml
│       │   ├── loki.yml
│       │   └── tempo.yml
│       └── dashboards/             # Auto-provisioned dashboards
│           ├── dashboards.yml
│           └── json/
│               ├── dashboard-1860.json    # Node Exporter Full
│               ├── dashboard-179.json     # Docker & System
│               ├── dashboard-893.json     # cAdvisor
│               └── dashboard-15172.json   # Node Quickstart
├── loki/
│   └── loki-config.yaml            # Log storage config
├── promtail/
│   └── promtail-config.yaml        # Log collection config
└── tempo/
    └── tempo-config.yaml           # Trace storage config
```

---

## 🔧 Configuration Highlights

### Prometheus

- **Retention**: 15 days
- **Scrape Interval**: 15 seconds
- **Targets**: Node Exporter, cAdvisor, Prometheus self-monitoring
- **Alert Rules**: CPU, memory, disk, service availability
- **Remote Write**: Tempo metrics generator

### Loki

- **Retention**: 30 days (720 hours)
- **Storage**: Local filesystem with compaction
- **Schema**: TSDB with v13 schema
- **Log Sources**: Docker containers (via Promtail)

### Tempo

- **Retention**: 30 days (720 hours)
- **Receivers**: OTLP gRPC (4317), OTLP HTTP (4318)
- **Storage**: Local filesystem
- **Features**: Service graphs, span metrics, trace correlation

### Grafana

- **Datasources**: Auto-provisioned (Prometheus, Loki, Tempo)
- **Dashboards**: 4 pre-built dashboards auto-imported
- **Theme**: Dark mode by default
- **Features**: Explore, Alerting, Unified Search

---

## 🚀 Deployment Best Practices

### Environment Variables

Create `.env` file in `docker/monitoring-stack/`:

```bash
GRAFANA_PORT=3001
PROMETHEUS_PORT=9090
ALERTMANAGER_PORT=9093
LOKI_PORT=3100
TEMPO_PORT=3200
CADVISOR_PORT=8080

GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=your-secure-password-here
```

### Volume Management

All data is persisted in Docker volumes:

```bash
# List monitoring volumes
docker volume ls | grep monitoring-stack

# Backup Grafana data
docker run --rm -v monitoring-stack_grafana_data:/data \
  -v $(pwd)/backups:/backup ubuntu tar czf /backup/grafana-$(date +%F).tar.gz /data

# Restore Grafana data
docker run --rm -v monitoring-stack_grafana_data:/data \
  -v $(pwd)/backups:/backup ubuntu tar xzf /backup/grafana-2024-11-02.tar.gz -C /
```

### Health Checks

Verify all services are healthy:

```bash
# Check container status
docker ps --filter "name=mon-" --format "table {{.Names}}\t{{.Status}}"

# Test endpoints
curl -s http://localhost:9090/-/healthy && echo " ✓ Prometheus"
curl -s http://localhost:3001/api/health && echo " ✓ Grafana"
curl -s http://localhost:3100/ready && echo " ✓ Loki"
curl -s http://localhost:3200/ready && echo " ✓ Tempo"
```

---

## 🔒 Security Considerations

### Network Isolation

- Services communicate via internal `monitoring` network
- Only necessary ports exposed to host
- No external internet access required for core functionality

### Secrets Management

- Grafana admin credentials in `.env` file (gitignored)
- AlertManager Slack webhook in `alertmanager.yml` (can use Ansible Vault)
- Use strong passwords in production

### SELinux Compatibility

All volume mounts use `:z` flag for SELinux compatibility on Fedora/RHEL:

```yaml
volumes:
  - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro,z
```

---

## 📊 Observability Features

### Unified Correlation

The stack provides **3 pillars of observability** with full correlation:

1. **Metrics** (Prometheus) → View in Grafana dashboards
2. **Logs** (Loki) → Click trace ID in logs → Jump to Tempo
3. **Traces** (Tempo) → Click log link in trace → Jump to Loki

### Example Workflow

1. **Alert fires** → AlertManager sends Slack notification
2. **View dashboard** → Grafana shows metric spike
3. **Check logs** → Loki shows error messages with trace IDs
4. **Trace request** → Tempo shows distributed trace across services
5. **Correlate** → Jump between metrics/logs/traces seamlessly

---

## 🛠️ Troubleshooting

### Service Won't Start

```bash
# Check logs
docker logs mon-<service-name>

# Common issues:
# 1. Port already in use
sudo lsof -i :9090  # Check if port is taken

# 2. Permission denied (SELinux)
sudo ausearch -m avc -ts recent  # Check SELinux denials

# 3. Config syntax error
docker compose -f docker/monitoring-stack/docker-compose.yml config
```

### Grafana Can't Connect to Datasources

```bash
# Check network connectivity
docker exec mon-grafana ping -c 2 prometheus
docker exec mon-grafana ping -c 2 loki
docker exec mon-grafana ping -c 2 tempo

# Verify datasource configs
ls -la docker/monitoring-stack/grafana/provisioning/datasources/
```

### High Memory Usage

```bash
# Check resource usage
docker stats --no-stream

# Reduce retention periods in configs:
# - Prometheus: storage.tsdb.retention.time
# - Loki: limits_config.retention_period
# - Tempo: compactor.compaction.block_retention
```

---

## 📚 Additional Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/grafana/latest/)
- [Loki Documentation](https://grafana.com/docs/loki/latest/)
- [Tempo Documentation](https://grafana.com/docs/tempo/latest/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

---

## 🔗 Related Pages

- [Monitoring & Observability](monitoring.md) - Alert rules and runbooks
- [Grafana Dashboards](grafana-dashboards.md) - Dashboard details and customization
- [Security Scanning](security.md) - Trivy container vulnerability scanning
- [Architecture](architecture.md) - System architecture diagrams
