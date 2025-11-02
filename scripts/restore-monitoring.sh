#!/usr/bin/env bash
# Restore Grafana dashboards and Prometheus data from backup
# Usage: ./scripts/restore-monitoring.sh <backup-file.tar.gz>

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <backup-file.tar.gz>"
    exit 1
fi

BACKUP_FILE="$1"
TEMP_DIR="/tmp/monitoring-restore-$$"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "Extracting backup..."
mkdir -p "$TEMP_DIR"
tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR"
BACKUP_DIR="$TEMP_DIR/$(ls "$TEMP_DIR")"

echo "Stopping monitoring stack..."
cd docker/monitoring-stack
docker compose down

echo "Restoring data..."
docker run --rm -v monitoring-stack_grafana_data:/data -v "$BACKUP_DIR/grafana":/backup alpine sh -c "cd /data && cp -r /backup/grafana/* ."
docker run --rm -v monitoring-stack_prometheus_data:/data -v "$BACKUP_DIR/prometheus":/backup alpine sh -c "cd /data && cp -r /backup/prometheus/* ."
docker run --rm -v monitoring-stack_alertmanager_data:/data -v "$BACKUP_DIR/alertmanager":/backup alpine sh -c "cd /data && cp -r /backup/alertmanager/* ."

echo "Starting monitoring stack..."
docker compose up -d

echo "Cleaning up..."
rm -rf "$TEMP_DIR"

echo "✅ Restore complete!"
echo "Check services: docker compose ps"
