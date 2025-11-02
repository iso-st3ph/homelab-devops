#!/bin/bash
# Deploy monitoring stack to K3s Kubernetes cluster

set -e

NAMESPACE="monitoring"
MANIFEST_DIR="$(dirname "$0")"

echo "🚀 Deploying Monitoring Stack to Kubernetes..."

# Set KUBECONFIG
export KUBECONFIG=~/.kube/config

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl first."
    exit 1
fi

# Check if cluster is running
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster. Is K3s running?"
    exit 1
fi

echo "✅ Connected to Kubernetes cluster"

# Create namespace if it doesn't exist
if ! kubectl get namespace $NAMESPACE &> /dev/null; then
    echo "📦 Creating namespace: $NAMESPACE"
    kubectl create namespace $NAMESPACE
else
    echo "✅ Namespace $NAMESPACE already exists"
fi

# Apply manifests in order
echo ""
echo "📝 Applying Kubernetes manifests..."

for manifest in $MANIFEST_DIR/*.yaml; do
    filename=$(basename "$manifest")
    echo "  → Applying $filename"
    kubectl apply -f "$manifest"
done

echo ""
echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l component=monitoring -n $NAMESPACE --timeout=300s || true

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Checking deployment status:"
kubectl get all -n $NAMESPACE

echo ""
echo "🌐 Access URLs:"
echo "  • Prometheus:    http://localhost:30090"
echo "  • Grafana:       http://localhost:30300 (admin/admin)"
echo "  • AlertManager:  http://localhost:30093"
echo ""
echo "📝 Useful commands:"
echo "  kubectl get pods -n $NAMESPACE"
echo "  kubectl logs -f <pod-name> -n $NAMESPACE"
echo "  kubectl describe pod <pod-name> -n $NAMESPACE"
echo ""
