#!/usr/bin/env bash
# Import pre-built Grafana dashboards from grafana.com
# Automatically provisions popular dashboards for Node Exporter, Docker, and cAdvisor

set -euo pipefail

DASHBOARDS_DIR="docker/monitoring-stack/grafana/provisioning/dashboards"
DASHBOARD_JSON_DIR="$DASHBOARDS_DIR/json"

# Create directories if they don't exist
mkdir -p "$DASHBOARD_JSON_DIR"

# Color output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Grafana Dashboard Importer ===${NC}"
echo ""

# Dashboard list: ID and name
declare -A DASHBOARDS=(
    ["1860"]="Node Exporter Full"
    ["179"]="Docker & System Monitoring"
    ["893"]="cAdvisor Prometheus"
    ["15172"]="Node Exporter Quickstart and Dashboard"
)

for DASHBOARD_ID in "${!DASHBOARDS[@]}"; do
    DASHBOARD_NAME="${DASHBOARDS[$DASHBOARD_ID]}"
    OUTPUT_FILE="$DASHBOARD_JSON_DIR/dashboard-${DASHBOARD_ID}.json"
    
    echo -e "${YELLOW}Downloading: ${DASHBOARD_NAME} (ID: ${DASHBOARD_ID})${NC}"
    
    # Download dashboard JSON from Grafana.com
    if curl -fsSL "https://grafana.com/api/dashboards/${DASHBOARD_ID}/revisions/latest/download" \
        -o "$OUTPUT_FILE"; then
        
        # Update datasource to use our Prometheus
        if command -v jq &> /dev/null; then
            jq '.dashboard.panels[].datasource = "Prometheus"' "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp" && \
                mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"
        fi
        
        echo -e "${GREEN}✓ Downloaded: ${OUTPUT_FILE}${NC}"
    else
        echo -e "${RED}✗ Failed to download dashboard ${DASHBOARD_ID}${NC}"
    fi
    
    echo ""
done

# Create dashboard provider configuration if it doesn't exist
PROVIDER_FILE="$DASHBOARDS_DIR/dashboards.yml"
if [ ! -f "$PROVIDER_FILE" ]; then
    echo -e "${YELLOW}Creating dashboard provider configuration...${NC}"
    cat > "$PROVIDER_FILE" <<EOF
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: 'Imported'
    type: file
    disableDeletion: false
    updateIntervalSeconds: 30
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards/json
      foldersFromFilesStructure: false
EOF
    echo -e "${GREEN}✓ Created: ${PROVIDER_FILE}${NC}"
fi

echo ""
echo -e "${GREEN}=== Dashboard Import Complete ===${NC}"
echo -e "Dashboards downloaded to: ${DASHBOARD_JSON_DIR}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Restart Grafana: docker compose -f docker/monitoring-stack/docker-compose.yml restart grafana"
echo "2. Access Grafana: http://localhost:3001"
echo "3. Navigate to: Dashboards → Browse → Imported folder"
echo ""
echo -e "${BLUE}Available Dashboards:${NC}"
for DASHBOARD_ID in "${!DASHBOARDS[@]}"; do
    echo "  - ${DASHBOARDS[$DASHBOARD_ID]} (ID: ${DASHBOARD_ID})"
done
