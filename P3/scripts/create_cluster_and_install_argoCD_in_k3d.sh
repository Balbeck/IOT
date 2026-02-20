#!/bin/bash

# Create cluster + expose ports 
k3d cluster create iot \
    -p "80:80@loadbalancer" \
    --agents 1
kubectl get nodes # Test
kubectl get pods -A 

# Create namespace for argocd and dev env
kubectl create namespace argocd
kubectl create namespace dev
kubectl get ns # Test

# To install k3d we first need to create a cluster !!!



# Install argocd (with UI, SSO and multi-cluster features)
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Test
kubectl get pods -n argocd

# Get ArgoCd admin password:
kubectl get secret argocd-initial-admin-secret \
    -n argocd \
    -o jsonpath="{.data.password}" | base64 -d
