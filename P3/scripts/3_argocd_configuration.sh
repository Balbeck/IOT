#!/bin/bash

# If something fails, option to auto stop the script
set -e

# VARS
ARGOCD_SERVER="argocd.localhost"
GIT_REPO="https://github.com/Balbeck/IOT.git"
GIT_BRANCH="main"
APP_NAME="iot-app"
APP_NAMESPACE="dev"
APP_PATH="P3/confs/k8s"


# Argocd CLI
echo "🏗️  Installing ArgoCD CLI..."
VERSION=$(curl -L -s https://raw.githubusercontent.com/argoproj/argo-cd/stable/VERSION)
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/v$VERSION/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
echo "✅  ArgoCD CLI installed !"

# Logging into ArgoCD
echo "🔐  Getting admin password..."
ARGO_PWD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)
echo "🔑  Logging into ArgoCD..."
argocd login $ARGOCD_SERVER \
  --username admin \
  --password $ARGO_PWD \
  --insecure
echo "✅  Succesfully connected to ArgoCD !"

# Creating the ArgoCD App
echo "🏗️  Creating ArgoCD App [ $APP_NAME ]..."
argocd app create $APP_NAME \
        --repo $GIT_REPO \
        --path $APP_PATH \
        --dest-server https://kubernetes.default.svc \
        --dest-namespace $APP_NAMESPACE \
        --sync-policy automated \
        --auto-prune \
        --self-heal

echo "⏳  Syncing app..."
argocd app sync $APP_NAME
echo "✅  App [ $APP_NAME ] is synced and will auto-deploy on each push to [ $GIT_BRANCH ]!"
