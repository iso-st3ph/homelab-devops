# Kubernetes Monitoring Stack

This directory contains Kubernetes manifests for deploying a complete observability stack on K3s.

## 🎯 Stack Components

| Service | Purpose | Access |
|---------|---------|--------|
| **Prometheus** | Metrics collection & storage | http://localhost:30090 |
| **Grafana** | Visualization & dashboards | http://localhost:30300 (admin/admin) |
| **Loki** | Log aggregation | Internal (port 3100) |
| **Tempo** | Distributed tracing | Internal (ports 3200, 4317, 4318) |
| **AlertManager** | Alert routing & notification | http://localhost:30093 |

## 🚀 Quick Start

### Prerequisites

- K3s installed and running
- kubectl configured (~/.kube/config)
- 10GB+ free disk space for PersistentVolumes

### Deploy All Services

```bash
# From repository root
make k8s-deploy

# Or manually
cd kubernetes/monitoring
./deploy.sh
```

### Check Status

```bash
make k8s-status

# Or manually
kubectl get all -n monitoring
kubectl get pvc -n monitoring
```

### View Logs

```bash
make k8s-logs

# Or manually
kubectl logs -f <pod-name> -n monitoring
```

## 📁 Manifest Structure

```
kubernetes/monitoring/
├── 00-namespace.yaml              # Monitoring namespace
├── 01-prometheus-configmap.yaml   # Prometheus configuration
├── 02-prometheus-rules.yaml       # Alert rules
├── 03-prometheus.yaml             # Prometheus deployment
├── 04-grafana.yaml                # Grafana deployment
├── 05-node-exporter.yaml          # Node metrics (DaemonSet)
├── 06-loki.yaml                   # Log aggregation
├── 07-tempo.yaml                  # Distributed tracing
├── 08-alertmanager.yaml           # Alert management
└── deploy.sh                      # Deployment script
```

## 🔧 Configuration

### Prometheus

- **Retention**: 15 days
- **Storage**: 10Gi PVC (local-path)
- **Scrape Interval**: 15s
- **Service Discovery**: Kubernetes API, static configs
- **RBAC**: ClusterRole with pod/node/service read access

**Key Features**:
- Kubernetes service discovery for pods, nodes, and services
- External labels: `cluster=k3s-homelab`, `environment=production`
- Auto-discovery of pods with `prometheus.io/scrape: "true"` annotation

### Grafana

- **Admin Credentials**: admin/admin (change after first login)
- **Storage**: 5Gi PVC
- **Plugins**: grafana-piechart-panel
- **Datasources**: Auto-provisioned (Prometheus, Loki, Tempo)

**Correlation Features**:
- Trace → Logs (via Loki)
- Trace → Metrics (via Prometheus)
- Logs → Traces (via Tempo)

### Loki

- **Retention**: 30 days (720h)
- **Storage**: 20Gi PVC
- **Schema**: v13 TSDB
- **Compaction**: Enabled with 10m interval

### Tempo

- **Retention**: 30 days (720h)
- **Storage**: 20Gi PVC
- **Receivers**: OTLP (gRPC:4317, HTTP:4318)
- **Metrics Generator**: Service graphs, span metrics

### AlertManager

- **Storage**: 2Gi PVC
- **Routes**: Critical (5m repeat), Warning (1h repeat)
- **Receivers**: Configurable (Slack, email, webhook)

## 🎯 Usage Examples

### Query Kubernetes Metrics

```bash
# Port-forward Prometheus
kubectl port-forward -n monitoring svc/prometheus 9090:9090

# Access http://localhost:9090 and query:
up{job="kubernetes-pods"}
kube_pod_status_phase{namespace="monitoring"}
```

### View Logs in Grafana

```bash
# Port-forward Grafana
kubectl port-forward -n monitoring svc/grafana 3000:3000

# Access http://localhost:3000
# Go to Explore → Select Loki
# Query: {namespace="monitoring"}
```

### Send Traces to Tempo

```bash
# OTLP gRPC endpoint (from within cluster)
tempo.monitoring.svc.cluster.local:4317

# OTLP HTTP endpoint
tempo.monitoring.svc.cluster.local:4318
```

## 📊 Monitoring Kubernetes

### Annotate Pods for Scraping

Add these annotations to your pod specs for auto-discovery:

```yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "8080"
    prometheus.io/path: "/metrics"
```

### Available Kubernetes Metrics

Prometheus scrapes these Kubernetes jobs automatically:
- `kubernetes-apiservers` - API server metrics
- `kubernetes-nodes` - Node metrics (kubelet)
- `kubernetes-pods` - Pod metrics (auto-discovered)

### Alert Rules

Pre-configured alerts in `02-prometheus-rules.yaml`:
- **NodeExporterDown** - Node metrics unavailable
- **HighCPUUsage** - CPU > 80% for 5m
- **HighMemoryUsage** - Memory > 90% for 5m
- **DiskSpaceLow** - Disk < 15% for 5m
- **PodCrashLooping** - Pod restarting frequently
- **PodNotReady** - Pod not ready for 10m

## 🔐 Security

### RBAC Configuration

Prometheus ServiceAccount has ClusterRole with permissions:
- **Resources**: nodes, services, endpoints, pods, ingresses
- **Verbs**: get, list, watch
- **Non-Resource URLs**: /metrics

### Network Policies

Services use ClusterIP (internal) except:
- Prometheus: NodePort 30090
- Grafana: NodePort 30300
- AlertManager: NodePort 30093

## 🛠️ Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl describe pod <pod-name> -n monitoring

# Check events
kubectl get events -n monitoring --sort-by='.lastTimestamp'

# Check PVC status
kubectl get pvc -n monitoring
```

### PersistentVolume Issues

```bash
# Check PV/PVC status
kubectl get pv,pvc -n monitoring

# K3s uses local-path-provisioner by default
kubectl get storageclass
```

### Port Conflicts

If running on same host as Docker stack, some ports may conflict:
- Node Exporter: 9100 (conflict expected, removed from K8s)
- Prometheus: Uses 30090 (NodePort) instead of 9090
- Grafana: Uses 30300 (NodePort) instead of 3000

### View Pod Logs

```bash
# Prometheus
kubectl logs -f deployment/prometheus -n monitoring

# Grafana
kubectl logs -f deployment/grafana -n monitoring

# Loki
kubectl logs -f deployment/loki -n monitoring
```

## 🧹 Cleanup

### Remove All Resources

```bash
make k8s-clean

# Or manually
kubectl delete namespace monitoring
```

### Remove Only Deployments (Keep PVCs)

```bash
kubectl delete deployment --all -n monitoring
kubectl delete daemonset --all -n monitoring
```

## 📈 Scaling

### Increase Replicas

```bash
kubectl scale deployment prometheus --replicas=2 -n monitoring
kubectl scale deployment grafana --replicas=2 -n monitoring
```

### Increase Storage

Edit PVC specs and apply:

```bash
kubectl edit pvc prometheus-pvc -n monitoring
# Change storage: 10Gi to storage: 20Gi
```

## 🔄 Updates

### Update Deployment

After modifying manifests:

```bash
kubectl apply -f kubernetes/monitoring/
```

### Rolling Update

```bash
kubectl rollout restart deployment/prometheus -n monitoring
kubectl rollout status deployment/prometheus -n monitoring
```

## 📚 Resources

- [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator)
- [Grafana on Kubernetes](https://grafana.com/docs/grafana/latest/setup-grafana/installation/kubernetes/)
- [K3s Documentation](https://docs.k3s.io/)
- [Kubernetes Monitoring Guide](https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/)

## 🎓 Next Steps

1. **Configure AlertManager**: Add Slack/email receivers
2. **Import Dashboards**: Use Grafana dashboard IDs 1860, 179, 893, 15172
3. **Enable ServiceMonitors**: If using Prometheus Operator
4. **Add Custom Alerts**: Extend `02-prometheus-rules.yaml`
5. **Set up GitOps**: Integrate with ArgoCD for declarative management
