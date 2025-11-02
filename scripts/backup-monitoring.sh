#!/usr/bin/env bash
# Backup Grafana dashboards and Prometheus data
# Usage: ./scripts/backup-monitoring.sh [backup-dir]

set -euo pipefail

BACKUP_DIR="${1:-./backups/monitoring/$(date +%Y-%m-%d_%H-%M-%S)}"
COMPOSE_DIR="./docker/monitoring-stack"

echo "Creating backup directory: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"/{grafana,prometheus,alertmanager}

# Backup Grafana data
echo "Backing up Grafana..."
docker cp mon-grafana:/var/lib/grafana "$BACKUP_DIR/grafana/"

# Backup Prometheus data
echo "Backing up Prometheus..."
docker cp mon-prometheus:/prometheus "$BACKUP_DIR/prometheus/"

# Backup AlertManager data
echo "Backing up AlertManager..."
docker cp mon-alertmanager:/alertmanager "$BACKUP_DIR/alertmanager/"

# Backup configurations
echo "Backing up configurations..."
cp -r "$COMPOSE_DIR/prometheus" "$BACKUP_DIR/config-prometheus"
cp -r "$COMPOSE_DIR/grafana" "$BACKUP_DIR/config-grafana"
cp -r "$COMPOSE_DIR/alertmanager" "$BACKUP_DIR/config-alertmanager"
cp "$COMPOSE_DIR/docker-compose.yml" "$BACKUP_DIR/"

# Create backup manifest
cat > "$BACKUP_DIR/manifest.txt" <<EOF
Backup Date: $(date)
Hostname: $(hostname)
Grafana Version: $(docker exec mon-grafana grafana-cli --version)
Prometheus Version: $(docker exec mon-prometheus prometheus --version | head -1)
AlertManager Version: $(docker exec mon-alertmanager alertmanager --version | head -1)
EOF

# Compress backup
echo "Compressing backup..."
tar -czf "$BACKUP_DIR.tar.gz" -C "$(dirname "$BACKUP_DIR")" "$(basename "$BACKUP_DIR")"
rm -rf "$BACKUP_DIR"

echo "✅ Backup complete: $BACKUP_DIR.tar.gz"
echo "Size: $(du -h "$BACKUP_DIR.tar.gz" | cut -f1)"
