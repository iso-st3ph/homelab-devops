#!/usr/bin/env bash
# Trivy vulnerability scanner for monitoring stack Docker images
# Scans for HIGH and CRITICAL vulnerabilities

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if trivy is installed
if ! command -v trivy &> /dev/null; then
    echo -e "${YELLOW}Trivy not found. Installing...${NC}"
    
    # Install trivy based on OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v dnf &> /dev/null; then
            # Fedora/RHEL
            sudo dnf install -y trivy
        elif command -v apt-get &> /dev/null; then
            # Debian/Ubuntu
            sudo apt-get update
            sudo apt-get install -y wget apt-transport-https gnupg lsb-release
            wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
            echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
            sudo apt-get update
            sudo apt-get install -y trivy
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install trivy
    fi
fi

# Images to scan from monitoring stack
IMAGES=(
    "prom/prometheus:latest"
    "grafana/grafana:latest"
    "prom/alertmanager:latest"
    "prom/node-exporter:latest"
    "gcr.io/cadvisor/cadvisor:latest"
)

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}    Trivy Security Scan - Monitoring Stack${NC}"
echo -e "${BLUE}==================================================${NC}"
echo ""

SCAN_FAILED=0
TOTAL_VULNS=0

for IMAGE in "${IMAGES[@]}"; do
    echo -e "${YELLOW}Scanning: ${IMAGE}${NC}"
    echo "---"
    
    # Run trivy scan
    if trivy image --severity HIGH,CRITICAL --format table "$IMAGE"; then
        echo -e "${GREEN}✓ Scan completed for ${IMAGE}${NC}"
    else
        echo -e "${RED}✗ Scan failed for ${IMAGE}${NC}"
        SCAN_FAILED=1
    fi
    
    echo ""
    echo "=================================================="
    echo ""
done

# Summary
echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}              Scan Summary${NC}"
echo -e "${BLUE}==================================================${NC}"
echo -e "Total images scanned: ${#IMAGES[@]}"

if [ $SCAN_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All scans completed successfully${NC}"
    echo ""
    echo -e "${YELLOW}Note: Vulnerabilities found above are informational.${NC}"
    echo -e "${YELLOW}Review and update base images regularly.${NC}"
    exit 0
else
    echo -e "${RED}✗ Some scans failed${NC}"
    exit 1
fi
