# AlertManager Configuration

AlertManager handles alerts sent by Prometheus and routes them to appropriate notification channels (Slack, PagerDuty, email, etc.).

## Features

- **Slack Integration**: Sends alerts to Slack channels
- **Alert Grouping**: Groups similar alerts to reduce noise
- **Inhibition Rules**: Suppresses lower-severity alerts when critical ones are firing
- **Severity Routing**: Different channels for critical vs warning alerts

## Configuration

### 1. Set Up Slack Webhook

1. Go to https://api.slack.com/messaging/webhooks
2. Create a new Slack app or use existing one
3. Enable Incoming Webhooks
4. Create webhook URLs for channels:
   - `#homelab-alerts` - General alerts
   - `#homelab-critical` - Critical alerts only

### 2. Configure Environment Variables

Add to `.env`:
```bash
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
ALERTMANAGER_PORT=9093
```

### 3. Alert Severity Levels

- **critical**: Immediate action required (service down, resource exhausted)
- **warning**: Attention needed soon (high usage, approaching limits)

## Alert Rules

Current alerts configured in `/prometheus/rules/alerts.yml`:

### Node Exporter Alerts
- `NodeExporterDown` - Node exporter stopped responding
- `HighCPUUsage` - CPU usage > 80% for 5 minutes
- `HighMemoryUsage` - Memory usage > 90% for 5 minutes
- `DiskSpaceLow` - Disk space < 15%
- `DiskSpaceWarning` - Disk space < 25%

### Docker Container Alerts
- `ContainerDown` - cAdvisor stopped responding
- `ContainerHighMemory` - Container using > 90% of memory limit

### Prometheus System Alerts
- `PrometheusTargetDown` - Any scrape target unreachable
- `PrometheusDown` - Prometheus itself is down
- `GrafanaDown` - Grafana dashboard unreachable

## Testing Alerts

### Method 1: Trigger Real Condition
```bash
# Test high CPU alert
stress --cpu 8 --timeout 360s

# Test disk space alert (CAREFUL!)
dd if=/dev/zero of=/tmp/testfile bs=1M count=10000
```

### Method 2: Simulate with PromQL
Access Prometheus UI at http://localhost:9090 and manually create alerts.

### Method 3: Send Test Alert
```bash
curl -X POST http://localhost:9093/api/v1/alerts \
  -H 'Content-Type: application/json' \
  -d '[{
    "labels": {
      "alertname": "TestAlert",
      "severity": "warning",
      "instance": "localhost:9100"
    },
    "annotations": {
      "summary": "This is a test alert",
      "description": "Testing AlertManager Slack integration"
    }
  }]'
```

## Access AlertManager UI

- **URL**: http://localhost:9093
- **Features**:
  - View active alerts
  - Silence alerts temporarily
  - View alert routing
  - Check receiver status

## Runbooks

Each alert includes a `runbook` annotation with quick troubleshooting commands:

**Example - HighCPUUsage**:
```bash
# Check top processes
top -b -n 1 | head -20

# Check recent CPU-heavy processes
ps aux --sort=-%cpu | head -10
```

**Example - DiskSpaceLow**:
```bash
# Check disk usage
df -h

# Find large directories
du -sh /* | sort -rh | head -10

# Find large files
find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null
```

## Customization

### Add New Receiver (PagerDuty example)
```yaml
receivers:
  - name: 'pagerduty-critical'
    pagerduty_configs:
      - service_key: 'YOUR_PAGERDUTY_KEY'
        severity: '{{ .CommonLabels.severity }}'
```

### Add Email Notifications
```yaml
receivers:
  - name: 'email-alerts'
    email_configs:
      - to: 'ops@example.com'
        from: 'alertmanager@example.com'
        smarthost: 'smtp.gmail.com:587'
        auth_username: 'your-email@gmail.com'
        auth_password: 'app-password'
```

### Custom Alert Routes
```yaml
routes:
  - match:
      team: 'database'
    receiver: 'dba-slack'
  
  - match_re:
      service: '^(postgres|mysql).*'
    receiver: 'database-oncall'
```

## Troubleshooting

### Alerts Not Sending to Slack
1. Check AlertManager logs: `docker logs mon-alertmanager`
2. Verify webhook URL in `.env`
3. Test webhook: `curl -X POST $SLACK_WEBHOOK_URL -d '{"text":"test"}'`
4. Check AlertManager UI for errors: http://localhost:9093

### Alerts Not Triggering
1. Check Prometheus rule evaluation: http://localhost:9090/rules
2. Verify alert is firing: http://localhost:9090/alerts
3. Check AlertManager receives alerts: http://localhost:9093/#/alerts

### Too Many Alerts
1. Adjust thresholds in `/prometheus/rules/alerts.yml`
2. Increase `group_wait` and `group_interval` in alertmanager.yml
3. Add inhibition rules to suppress related alerts

## Production Best Practices

- [ ] Use separate Slack channels for different severity levels
- [ ] Set up on-call rotations with PagerDuty integration
- [ ] Create runbooks for each alert with resolution steps
- [ ] Test alert routing regularly
- [ ] Monitor AlertManager itself with external monitoring
- [ ] Keep alert rules in version control
- [ ] Document alert thresholds and business impact
- [ ] Review and tune alert thresholds monthly
