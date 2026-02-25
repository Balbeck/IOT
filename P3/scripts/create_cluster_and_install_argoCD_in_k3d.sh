#!/bin/bash

# Fct to create Namespace in the cluster
create_namespace() {
    NAMESPACE=$1
    if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
        kubectl create namespace "$NAMESPACE"
    fi
    echo "Waiting for namespace $NAMESPACE to be Active..."
    kubectl wait --for=condition=Established --timeout=30s \
        namespace "$NAMESPACE" >/dev/null 2>&1 || true
    # Verification
    while [[ $(kubectl get namespace "$NAMESPACE" -o jsonpath='{.status.phase}') != "Active" ]]; do
        sleep 1
    done
    echo "✅️ Namespace [ $NAMESPACE ] is ready !"
}


set -e

# Create Cluster
if k3d cluster list | grep -q "iot"; then
    echo "Cluster \'iot\' already exists!"
    echo "deleting cluster \'iot\'..."
    k3d cluster delete iot 2>/dev/null || true
fi
echo "Creating new k3d cluster..."
k3d cluster create iot -p "80:80@loadbalancer" --agents 1

# Waiting for cluster to be ready before going on
echo "Waiting for cluster to be ready..."
until kubectl get nodes >/dev/null 2>&1; do
    echo "Waiting for K8s API..."
    sleep 2
done
echo "✅️ K8s API is ready !"

echo "Waiting for nodes to be ready..."
while [[ $(kubectl get nodes --no-headers 2>/dev/null | awk '{print $2}') != "Ready" ]]; do
    echo "Waiting for nodes to be on Ready state..."
    sleep 2
done
echo "✅️ Cluster \'iot\' is Ready !"

# # Or simply...
# kubectl wait --for=condition=Ready node --all --timeout=30s


# Create namespaces
echo "Creating namespaces..."
create_namespace argocd
create_namespace dev

# # Or simply...
# kubectl create namespace argocd 2>/dev/null || true
# kubectl wait --for=jsonpath='{.status.phase}'=Active --timeout=30s namespace argocd
# kubectl create namespace dev 2>/dev/null || true
# kubectl wait --for=jsonpath='{.status.phase}'=Active --timeout=30s namespace dev



# Install ArgoCD
echo "Installing ArgoCD..."
kubectl apply -n argocd \
-f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for Argo CD pods to be ready..."
kubectl wait --for=condition=available deployment --all -n argocd --timeout=300s
echo "✅️ Argo CD installed successfully!"

# Get ArgoCd admin password:
echo "🔑 Admin password:"
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d

echo "✅️ Argo CD is accessible via port-forward or ingress."
