#!/bin/bash

# Create namespace for argocd and dev env
kubectl create namespace argocd
kubectl create namespace dev

# To install k3d we first need to create a cluster !!!



# Install argocd (with UI, SSO and multi-cluster features)
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Test
kubectl get pods -n argocd
