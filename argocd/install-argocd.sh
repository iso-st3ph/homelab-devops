#!/bin/bash
# Deploy ArgoCD to K3s cluster and configure GitOps workflow

set -e

echo "🚀 Deploying ArgoCD GitOps Platform..."

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

# Create ArgoCD namespace
if ! kubectl get namespace argocd &> /dev/null; then
    echo "📦 Creating namespace: argocd"
    kubectl create namespace argocd
else
    echo "✅ Namespace argocd already exists"
fi

# Install ArgoCD
echo ""
echo "📝 Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo ""
echo "⏳ Waiting for ArgoCD server to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Patch ArgoCD server service to use NodePort
echo ""
echo "🌐 Exposing ArgoCD server via NodePort..."
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort", "ports": [{"port": 443, "targetPort": 8080, "nodePort": 30443, "name": "https"}]}}'

# Get initial admin password
echo ""
echo "🔑 Retrieving ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "✅ ArgoCD installation complete!"
echo ""
echo "📊 ArgoCD Status:"
kubectl get pods -n argocd

echo ""
echo "🌐 Access ArgoCD UI:"
echo "  URL: https://localhost:30443"
echo "  Username: admin"
echo "  Password: $ARGOCD_PASSWORD"
echo ""
echo "📝 Next steps:"
echo "  1. Apply AppProject: kubectl apply -f argocd/appproject-homelab.yaml"
echo "  2. Apply Applications: kubectl apply -f argocd/monitoring-stack.yaml"
echo "  3. Access UI and explore GitOps workflow"
echo ""
echo "🔧 Useful commands:"
echo "  kubectl get applications -n argocd"
echo "  kubectl get appprojects -n argocd"
echo "  kubectl describe application monitoring-stack -n argocd"
echo ""
