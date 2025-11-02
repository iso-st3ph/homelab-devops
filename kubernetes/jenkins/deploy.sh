#!/bin/bash

set -e

echo "🚀 Deploying Jenkins to Kubernetes..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl."
    exit 1
fi

# Check cluster connectivity
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster."
    exit 1
fi

echo "✅ Kubernetes cluster reachable"

# Apply Jenkins manifests
echo "📦 Creating Jenkins namespace..."
kubectl apply -f 00-namespace.yaml

echo "🔐 Creating ServiceAccount and RBAC..."
kubectl apply -f 01-serviceaccount.yaml

echo "💾 Creating PersistentVolumeClaim..."
kubectl apply -f 02-pvc.yaml

echo "⚙️  Creating ConfigMap..."
kubectl apply -f 03-configmap.yaml

echo "🚀 Deploying Jenkins..."
kubectl apply -f 04-deployment.yaml

echo "🌐 Creating Services..."
kubectl apply -f 05-service.yaml

echo ""
echo "⏳ Waiting for Jenkins pod to be ready (this may take 2-3 minutes)..."
kubectl wait --for=condition=ready pod -l app=jenkins -n jenkins --timeout=300s

echo ""
echo "✅ Jenkins deployment complete!"
echo ""
echo "📊 Deployment Status:"
kubectl get pods,svc,pvc -n jenkins

echo ""
echo "🔑 Getting Jenkins initial admin password..."
sleep 10
JENKINS_POD=$(kubectl get pods -n jenkins -l app=jenkins -o jsonpath='{.items[0].metadata.name}')
echo "Run this command to get the admin password:"
echo "kubectl exec -n jenkins $JENKINS_POD -- cat /var/jenkins_home/secrets/initialAdminPassword"

echo ""
echo "🌐 Access Jenkins UI:"
echo "   URL: http://localhost:30808"
echo "   Username: admin"
echo "   Password: (run command above)"
echo ""
echo "💡 Useful commands:"
echo "   kubectl logs -n jenkins $JENKINS_POD -f              # Follow logs"
echo "   kubectl get pods -n jenkins                          # Check status"
echo "   kubectl exec -it -n jenkins $JENKINS_POD -- bash    # Shell access"
