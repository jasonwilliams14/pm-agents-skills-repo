#!/usr/bin/env bash
# vcluster CLI Quick Reference
# Source: skills/vcluster-dev/templates/vcluster-cli-quickref.sh
# Copy and paste commands below for common vcluster operations

# ============================================================================
# INSTALLATION
# ============================================================================

# Install vcluster CLI — macOS
brew install vcluster

# Install vcluster CLI — Linux
curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64"
chmod +x vcluster && sudo mv vcluster /usr/local/bin/

# Verify installation
vcluster version

# ============================================================================
# CLUSTER LIFECYCLE
# ============================================================================

# Create a local vcluster (requires host cluster, e.g. Docker Desktop)
vcluster create my-cluster --namespace vcluster-my-cluster

# Create vcluster with custom K3s version
vcluster create my-cluster --namespace vcluster-my-cluster \
  --set controlPlane.distro=k3s \
  --set controlPlane.k3s.image=rancher/k3s:v1.28.0

# Create vcluster for cloud (GKE example)
# First: kubectl config use-context gke_PROJECT_ZONE_CLUSTER_NAME
vcluster create staging-cluster --namespace vcluster-staging --host gke

# List all vclusters in namespace
vcluster list --namespace vcluster-my-cluster

# List all vclusters across all namespaces
vcluster list --all-namespaces

# ============================================================================
# CONNECTIVITY
# ============================================================================

# Connect to vcluster (merges kubeconfig, switches context)
vcluster connect my-cluster --namespace vcluster-my-cluster

# Connect and merge into existing kubeconfig (non-interactive)
vcluster connect my-cluster --namespace vcluster-my-cluster --update-current=false

# Print standalone kubeconfig (useful for external tools)
vcluster connect my-cluster --namespace vcluster-my-cluster --print-kubeconfig > vcluster-kubeconfig.yaml

# Use exported kubeconfig
kubectl --kubeconfig=vcluster-kubeconfig.yaml get pods

# Disconnect (restore previous context)
# Just run: vcluster disconnect (if using vcluster connect)
# Or manually: kubectl config use-context ORIGINAL_CONTEXT

# ============================================================================
# MANAGEMENT
# ============================================================================

# Delete a vcluster
vcluster delete my-cluster --namespace vcluster-my-cluster

# Delete vcluster without confirmation
vcluster delete my-cluster --namespace vcluster-my-cluster --force

# Resume a vcluster (if paused/stopped)
vcluster resume my-cluster --namespace vcluster-my-cluster

# Pause a vcluster (stops control plane, keeps resources)
vcluster pause my-cluster --namespace vcluster-my-cluster

# ============================================================================
# DEBUGGING
# ============================================================================

# Get vcluster status
vcluster list --namespace vcluster-my-cluster

# View vcluster logs (from host cluster context)
kubectl logs -n vcluster-my-cluster -l app.kubernetes.io/name=vcluster

# View syncer logs (bridges virtual cluster to host)
kubectl logs -n vcluster-my-cluster deployment/my-cluster

# Describe vcluster pod (from host context)
kubectl describe pod -n vcluster-my-cluster -l app.kubernetes.io/name=vcluster

# Shell into vcluster control plane for debugging
kubectl exec -it -n vcluster-my-cluster deployment/my-cluster -- sh

# ============================================================================
# PORT FORWARDING (Access vcluster from outside)
# ============================================================================

# Expose vcluster API to localhost
# Requires: kubectl port-forward (from host cluster context)
kubectl port-forward -n vcluster-my-cluster svc/my-cluster 6443:443 &

# Expose service inside vcluster to localhost
# Usage: After connecting to vcluster or from vcluster context
kubectl port-forward -n app-test svc/my-app 8080:80 &

# Kill port-forward
# List: jobs
# Kill: kill %1 (or fg then Ctrl+C)

# ============================================================================
# KUBECONFIG MANAGEMENT
# ============================================================================

# Export kubeconfig for standalone access (no context switching)
vcluster connect my-cluster --namespace vcluster-my-cluster --print-kubeconfig > ~/.kube/configs/vcluster-my-cluster

# Use exported kubeconfig with helm
helm --kubeconfig=~/.kube/configs/vcluster-my-cluster list

# Set KUBECONFIG env var
export KUBECONFIG=~/.kube/configs/vcluster-my-cluster
kubectl get nodes

# Switch back to default kubeconfig
unset KUBECONFIG

# ============================================================================
# COMMON WORKFLOWS
# ============================================================================

# Create 2 local vclusters for multi-cluster testing
vcluster create cluster-a --namespace vcluster-a
vcluster create cluster-b --namespace vcluster-b

# Connect to cluster-a, deploy app
vcluster connect cluster-a --namespace vcluster-a
kubectl apply -f my-app.yaml
kubectl get pods

# In new terminal: connect to cluster-b, deploy same app
vcluster connect cluster-b --namespace vcluster-b
kubectl apply -f my-app.yaml
kubectl get pods

# Cleanup both clusters
vcluster delete cluster-a --namespace vcluster-a
vcluster delete cluster-b --namespace vcluster-b

# ============================================================================
# HELM INTEGRATION
# ============================================================================

# Add Helm repo while connected to vcluster
vcluster connect my-cluster --namespace vcluster-my-cluster
helm repo add stable https://charts.helm.sh/stable
helm repo update

# Install Helm chart in vcluster
helm install my-release stable/nginx-ingress --namespace app-test

# List Helm releases
helm list --namespace app-test

# ============================================================================
# TIPS
# ============================================================================

# Tip 1: vcluster namespace convention
#   vcluster stores clusters in namespaces named: vcluster-{cluster-name}
#   Always use: --namespace vcluster-{name}

# Tip 2: Host cluster requirements
#   vcluster needs a parent Kubernetes cluster (host)
#   Host options: Docker Desktop, GKE, EKS, k3d, kind, etc.

# Tip 3: Fast feedback loop
#   Create/delete vcluster: 5-10 seconds (vs k3d: 2-3 minutes)
#   Perfect for rapid iteration and testing

# Tip 4: Resource usage
#   Each vcluster: 512MB-1GB RAM
#   Run 20+ clusters on a 16GB laptop

# Tip 5: Multiple vclusters
#   To test multi-cluster scenarios, create several vcluster instances
#   Each runs in its own namespace, fully isolated

# ============================================================================
# REFERENCES
# ============================================================================

# Official docs: https://www.vcluster.sh/docs/
# Quick start: https://www.vcluster.sh/docs/getting-started/setup
# API reference: https://www.vcluster.sh/docs/operator/api-reference
