# Grafana Dashboards

This project includes **4 pre-built production dashboards** automatically provisioned from [Grafana.com](https://grafana.com/grafana/dashboards/). These dashboards provide comprehensive visibility into system metrics, container performance, and infrastructure health.

---

## 📊 Available Dashboards

### 1. Node Exporter Full (ID: 1860)

**Purpose:** Complete system monitoring for Linux servers  
**Metrics Covered:**
- CPU usage (user, system, iowait, steal)
- Memory utilization (used, cached, buffered, swap)
- Disk I/O (read/write throughput, IOPS)
- Network traffic (bandwidth, errors, drops)
- Filesystem usage (disk space, inodes)
- System load averages (1min, 5min, 15min)

**Use Cases:**
- Capacity planning and trend analysis
- Performance troubleshooting
- Resource optimization
- SLA monitoring

**Visualization Highlights:**
- Time-series graphs with zoom/pan
- Heatmaps for latency distribution
- Gauge panels for current utilization
- Table view for multi-server comparison

---

### 2. Docker & System Monitoring (ID: 179)

**Purpose:** Docker container and host system overview  
**Metrics Covered:**
- Container count (running/stopped/paused)
- CPU usage per container
- Memory consumption per container
- Network I/O per container
- Block I/O per container
- Host system metrics

**Use Cases:**
- Container resource allocation
- Troubleshooting container performance issues
- Identifying resource-hungry containers
- Planning container migrations

**Visualization Highlights:**
- Single-pane view of all containers
- Color-coded status indicators
- Sortable container tables
- Host vs. container resource split

---

### 3. cAdvisor Prometheus (ID: 893)

**Purpose:** Detailed container metrics from cAdvisor  
**Metrics Covered:**
- Per-container CPU throttling
- Memory working set and RSS
- Filesystem usage by container
- Network bandwidth per interface
- Container restart counts
- OOM kill events

**Use Cases:**
- Deep-dive container diagnostics
- Memory leak detection
- CPU throttling analysis
- Network bottleneck identification

**Visualization Highlights:**
- Container-level drill-down
- Multi-axis graphs (CPU + memory)
- Alert annotation overlays
- Historical trend comparison

---

### 4. Node Exporter Quickstart (ID: 15172)

**Purpose:** Simplified node metrics dashboard  
**Metrics Covered:**
- Essential CPU, memory, disk metrics
- Quick health status overview
- Key performance indicators (KPIs)
- Top processes by resource usage

**Use Cases:**
- At-a-glance system health checks
- Executive/manager-friendly views
- Lightweight alternative to Full dashboard
- Mobile-friendly layout

**Visualization Highlights:**
- Large stat panels for quick reading
- Green/yellow/red color coding
- Minimal clutter, maximum clarity
- Auto-refresh every 30 seconds

---

## 🚀 Quick Start

### Import Dashboards

Run the automated import script:

```bash
# Import all 4 dashboards
make grafana-dashboards

# Or manually:
./scripts/import-grafana-dashboards.sh
```

**What it does:**
1. Downloads dashboard JSON from Grafana.com
2. Configures datasources to use local Prometheus
3. Creates dashboard provider configuration
4. Saves dashboards to `docker/monitoring-stack/grafana/provisioning/dashboards/json/`

### Restart Grafana

```bash
# Restart Grafana container to load new dashboards
docker compose -f docker/monitoring-stack/docker-compose.yml restart grafana

# Or restart entire monitoring stack
make mon-down && make mon-up
```

### Access Dashboards

1. Open Grafana: [http://localhost:3000](http://localhost:3000)
2. Login (default: `admin` / `changeme-please`)
3. Navigate: **Dashboards → Browse → Imported** folder
4. Select any dashboard to view

---

## 📁 File Structure

```
docker/monitoring-stack/grafana/
├── provisioning/
│   ├── dashboards/
│   │   ├── dashboards.yml          # Auto-provisioning config
│   │   └── json/
│   │       ├── dashboard-1860.json  # Node Exporter Full
│   │       ├── dashboard-179.json   # Docker & System
│   │       ├── dashboard-893.json   # cAdvisor
│   │       └── dashboard-15172.json # Node Exporter Quickstart
│   └── datasources/
│       └── prometheus.yml          # Prometheus datasource
```

---

## 🔧 Customization

### Modify Dashboard Variables

Dashboards use **template variables** for dynamic filtering:

1. Edit a dashboard in Grafana UI
2. Click **Settings ⚙️ → Variables**
3. Modify existing variables or add new ones:
   - `instance` - Select specific servers
   - `container` - Filter by container name
   - `device` - Choose network/disk devices
   - `interval` - Adjust scrape intervals

### Change Refresh Rate

1. Click **Dashboard settings ⚙️**
2. Go to **Time options**
3. Set **Auto refresh**: `5s, 10s, 30s, 1m, 5m`
4. Save dashboard

### Add Annotations

Display alert events on graphs:

1. **Settings ⚙️ → Annotations**
2. Add new annotation query:
   ```promql
   ALERTS{alertstate="firing"}
   ```
3. Alerts will appear as vertical lines on graphs

### Clone and Modify

To create custom versions:

1. Open dashboard → **Share** icon
2. Click **Export** → **Save to file**
3. Edit JSON file (change title, panels, queries)
4. Import via **Dashboards → Import → Upload JSON**

---

## 🎨 Dashboard Best Practices

### DO ✅

- **Use folders** - Organize by team/service (Imported, Custom, SRE)
- **Set time ranges** - Default to Last 6 hours for operational dashboards
- **Enable auto-refresh** - 30s-1m for real-time monitoring
- **Add descriptions** - Use panel descriptions for query explanations
- **Version control** - Export dashboards to Git after changes
- **Use variables** - Make dashboards reusable across environments

### DON'T ❌

- **Overload panels** - Max 12 panels per row for readability
- **Use default titles** - Rename "Panel Title" to meaningful names
- **Hardcode instances** - Always use variables like `$instance`
- **Mix time ranges** - Keep all panels on same time window
- **Forget alerts** - Link related alerts to dashboard panels
- **Skip legends** - Always label graph series clearly

---

## 📊 Example: Creating a Custom Dashboard

### Step 1: Start from Template

```bash
# Import Node Exporter Full as base
# Open in Grafana → Save As → "My Custom Dashboard"
```

### Step 2: Add Custom Panel

1. Click **Add panel** → **Add new visualization**
2. Write Prometheus query:
   ```promql
   rate(container_cpu_usage_seconds_total{name="mon-prometheus"}[5m]) * 100
   ```
3. Set **Panel title**: "Prometheus CPU Usage"
4. Choose **Visualization**: Time series
5. Configure **Thresholds**: 50% (yellow), 80% (red)
6. Click **Apply**

### Step 3: Add Business Metrics

Example: Application request rate

```promql
sum(rate(http_requests_total[5m])) by (service)
```

### Step 4: Export and Version

```bash
# Export dashboard JSON
# Save to: docker/monitoring-stack/grafana/provisioning/dashboards/json/custom-app.json

# Commit to Git
git add docker/monitoring-stack/grafana/provisioning/dashboards/json/custom-app.json
git commit -m "feat(grafana): add custom application dashboard"
```

---

## 🔗 Integration with Prometheus

### Verify Datasource

Check Prometheus datasource is configured:

```bash
# View datasource config
cat docker/monitoring-stack/grafana/provisioning/datasources/prometheus.yml
```

Expected output:

```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
```

### Test Queries

In Grafana **Explore** view, test queries:

```promql
# All available metrics
{__name__=~".+"}

# Node Exporter metrics
node_cpu_seconds_total

# cAdvisor metrics
container_memory_usage_bytes

# Custom app metrics (if instrumented)
myapp_http_requests_total
```

---

## 🛠️ Troubleshooting

### Dashboards Not Appearing

**Problem:** Dashboards don't show in Grafana UI

**Solution:**

1. Check provisioning directory:
   ```bash
   ls -la docker/monitoring-stack/grafana/provisioning/dashboards/json/
   ```

2. Verify dashboard provider config exists:
   ```bash
   cat docker/monitoring-stack/grafana/provisioning/dashboards/dashboards.yml
   ```

3. Check Grafana logs:
   ```bash
   docker logs mon-grafana | grep -i dashboard
   ```

4. Restart Grafana:
   ```bash
   docker compose -f docker/monitoring-stack/docker-compose.yml restart grafana
   ```

### "No Data" in Panels

**Problem:** Dashboard loads but panels show "No data"

**Solution:**

1. Verify Prometheus is scraping targets:
   - Open [http://localhost:9090/targets](http://localhost:9090/targets)
   - All targets should be **UP**

2. Check metric names in Prometheus:
   ```promql
   # Search for node_exporter metrics
   {job="node-exporter"}
   ```

3. Adjust time range:
   - Click time picker (top-right)
   - Select **Last 6 hours** or **Last 24 hours**

4. Verify datasource in panel:
   - Edit panel → **Query** tab
   - Datasource should be **Prometheus** (not `-- Mixed --`)

### Slow Dashboard Loading

**Problem:** Dashboards take >10 seconds to load

**Solution:**

1. Reduce time range (Last 1 hour instead of Last 7 days)
2. Increase scrape interval in `prometheus.yml`:
   ```yaml
   scrape_configs:
     - job_name: node-exporter
       scrape_interval: 30s  # Instead of 15s
   ```
3. Enable query caching in Grafana:
   ```yaml
   # grafana.ini
   [caching]
   enabled = true
   ```

4. Optimize PromQL queries (use `rate()` instead of `irate()` for less data points)

---

## 📚 Additional Resources

### Official Documentation

- [Grafana Dashboards Guide](https://grafana.com/docs/grafana/latest/dashboards/)
- [Prometheus Query Examples](https://prometheus.io/docs/prometheus/latest/querying/examples/)
- [Dashboard Best Practices](https://grafana.com/docs/grafana/latest/best-practices/best-practices-for-creating-dashboards/)

### Community Dashboards

Browse 10,000+ dashboards:
- [Grafana.com Dashboard Library](https://grafana.com/grafana/dashboards/)
- Filter by: Data source (Prometheus), Tags (docker, linux, kubernetes)

### Video Tutorials

- [Grafana Fundamentals](https://grafana.com/tutorials/grafana-fundamentals/)
- [Building Your First Dashboard](https://www.youtube.com/watch?v=sKNZMtoSHN4)

---

## 🎯 Next Steps

1. **Explore dashboards** - Click through all 4 imported dashboards
2. **Customize variables** - Adjust filters for your environment
3. **Create alerts** - Add alerting rules to dashboard panels
4. **Export and backup** - Save dashboards to Git for version control
5. **Share dashboards** - Generate snapshot links for team sharing

---

**Pro Tip:** Set your most-used dashboard as **Home Dashboard** in Grafana preferences for quick access on login!
