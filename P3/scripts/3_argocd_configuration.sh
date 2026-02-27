#!/bin/bash

set -e

# VARS
IOT_APP_PORT="30042"
ARGOCD_EXPOSED_PORT="30021"
ARGOCD_SERVER="localhost:$ARGOCD_EXPOSED_PORT"
GIT_REPO="https://github.com/Balbeck/IOT.git"
GIT_BRANCH="main"
APP_NAME="iot-app"
APP_NAMESPACE="dev"
APP_PATH="P3/confs/k8s"


# Logging into ArgoCD
echo "🔐  Getting admin password..."
ARGO_PWD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)
# echo $ARGO_PWD


echo "⏳  Waiting for ArgoCD server to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s
echo "✅  ArgoCD server is Ready!"


echo "🔑  Logging into ArgoCD..."
argocd login $ARGOCD_SERVER \
  --username admin \
  --password $ARGO_PWD \
  --insecure
echo "✅  Succesfully connected to ArgoCD !"


# Creating the ArgoCD App
echo ""
echo "🏗️  Building ArgoCD App [ $APP_NAME ]..."
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
echo "reach wil42 web App at: localhost:$IOT_APP_PORT"
