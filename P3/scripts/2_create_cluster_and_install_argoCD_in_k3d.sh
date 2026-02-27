#!/bin/bash

ARGOCD_EXPOSED_PORT="30021"
IOT_APP_PORT="30042"

# Fct to create Namespace in the cluster
create_namespace() {
    NAMESPACE=$1
    if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
        kubectl create namespace "$NAMESPACE"
    fi
    echo "⏳ Waiting for namespace $NAMESPACE to be Active..."
    kubectl wait --for=condition=Established --timeout=30s \
        namespace "$NAMESPACE" >/dev/null 2>&1 || true
    # Verification
    while [[ $(kubectl get namespace "$NAMESPACE" -o jsonpath='{.status.phase}') != "Active" ]]; do
        sleep 1
    done
    echo "✅️ Namespace [ $NAMESPACE ] is ready !"
}

# If something fails, option to auto stop the script
set -e

# Create Cluster
if k3d cluster list | grep -q "iot"; then
    echo "🚫  Cluster [ iot ] already exists!"
    echo "🗑️  Deleting cluster [ iot ]..."
    k3d cluster delete iot 2>/dev/null || true
fi
echo "🏗️  Building new k3d cluster..."
# k3d cluster create iot -p "80:80@loadbalancer" --agents 1
k3d cluster create iot -p "80:80@loadbalancer" -p "$ARGOCD_EXPOSED_PORT:$ARGOCD_EXPOSED_PORT@loadbalancer" -p "$IOT_APP_PORT:$IOT_APP_PORT@loadbalancer" --agents 1

# Waiting for cluster to be ready before going on
echo "⏳  Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready node --all --timeout=120s
echo "✅️  K8s API is ready !"
echo "✅️  Cluster [ iot ] is Ready !"

# Create namespaces
echo "🏗️  Building namespaces..."
create_namespace argocd
create_namespace dev

# # Or simply...
# kubectl create namespace argocd 2>/dev/null || true
# kubectl wait --for=jsonpath='{.status.phase}'=Active --timeout=30s namespace argocd
# kubectl create namespace dev 2>/dev/null || true
# kubectl wait --for=jsonpath='{.status.phase}'=Active --timeout=30s namespace dev

# Install ArgoCD
echo "🏗️  Installing ArgoCD..."
kubectl apply -n argocd --server-side --force-conflicts -f \
    https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


echo "⏳  Waiting for Argo CD pods to be deployed..."
kubectl wait --for=condition=available deployment --all -n argocd --timeout=300s
echo "✅️  Argo CD installed successfully!"


# Enable insecure mode (disable internal TLS) for ArgoCD
echo "🔧 Configuring ArgoCD..."
kubectl patch configmap argocd-cmd-params-cm -n argocd \
    -p '{"data":{"server.insecure":"true"}}'


# Restart ArgoCD server to apply config + Expose port
echo "🔧 Applying ports configuration..."
kubectl apply -f ./../confs/argocd-service-exposure.yaml
echo "🔧 Restarting Deployment Server ..."
kubectl rollout restart deployment argocd-server -n argocd
echo "⏳  Waiting for all ArgoCD pods to be Up and Running..."
kubectl wait --for=condition=ready pod --all -n argocd --timeout=120s
kubectl get pods -n argocd
echo "✅️  All the argocd pods are Up and Running!"


# Argocd CLI
echo "🏗️  Installing ArgoCD CLI..."
VERSION=$(curl -L -s https://raw.githubusercontent.com/argoproj/argo-cd/stable/VERSION)
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/v$VERSION/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
echo "✅  ArgoCD CLI installed !"


echo "🌍  ArgoCD's UI is available at :  http://localhost:$ARGOCD_EXPOSED_PORT "
# Get ArgoCd admin password: [user: admin]
echo "🔑 with Admin password:"
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
echo ""
