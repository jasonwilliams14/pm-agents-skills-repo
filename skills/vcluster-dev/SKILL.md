---
name: vcluster-dev
description: Use when setting up local or cloud-based virtual Kubernetes clusters for testing isolation, rapid cluster turnover, or validating workloads with reduced infrastructure overhead; especially when existing tools (Kind, k3d) don't meet resource or multi-tenancy constraints.
---

# vcluster Development & Testing

## Overview

**vcluster** is a Kubernetes-native tool that creates fully functional virtual Kubernetes clusters at the pod level (not VM level). Unlike Kind or k3d, which run entire Kubernetes clusters in containers, vcluster provisions lightweight virtual clusters that share a host cluster's kernel and control plane, dramatically reducing resource overhead.

**Core principle:** Use vcluster when you need rapid cluster turnover, multi-tenant isolation, or resource-constrained testing—both locally and in cloud environments.

---

## When to Use vcluster

### Use vcluster When:

- **Multi-cluster testing** — Test federation, cross-cluster communication, or failover scenarios (10+ isolated clusters on one machine)
- **Rapid iteration** — Spin up/tear down clusters in 5-10 seconds vs k3d's 2-3 minutes
- **Resource constraints** — Each vcluster uses 512MB–1GB RAM; run 20+ clusters on a laptop
- **Multi-tenancy validation** — Test namespace isolation, RBAC policies, or cluster quotas
- **Cloud-parity testing** — Deploy identical vcluster configurations to local Docker, GCP, AWS, or Azure
- **Dependency testing** — Validate workloads against different Kubernetes API versions (vcluster runs K3s, Vanilla K8s, or EKS distros)

### When NOT to Use vcluster:

- **Production hardware validation** — vcluster can't test GPU scheduling, node affinity, or hardware-specific workloads
- **GKE-specific features** — Workload Identity, Config Connector, GCP-native APIs have no direct equivalent in vcluster (requires staging on real GKE)
- **Performance/load testing** — Pod-level isolation doesn't replicate cluster-scale networking or scheduler behavior
- **Single-cluster dev** — k3d is simpler and faster for one-off testing

---

## Architecture & Key Differences

| Aspect | vcluster | k3d | Kind |
|--------|----------|-----|------|
| **Isolation Level** | Pod (lightweight) | VM (Docker container) | VM (Docker container) |
| **Startup Time** | 5-10s | 2-3min | 4-6min |
| **RAM per Cluster** | 512MB–1GB | 2–4GB | 2–4GB |
| **Parallel Clusters** | 20+ on laptop | 2-3 max | 2-3 max |
| **Parent Cluster Required** | ✓ Yes | ✗ No | ✗ No |
| **Multi-tenancy Testing** | ✓ Excellent | ✗ Limited | ✗ Limited |
| **Production-Like Networking** | ✓ Pod network | ✓ Container network | ✓ Container network |

**Why the parent cluster requirement?** vcluster runs inside pods on a host cluster—it doesn't spin up standalone VMs. This is a feature: you control the host environment (Docker Desktop, GKE, EKS, etc.) and deploy identical vcluster configs across platforms.

---

## Quick Reference: Setup & Common Tasks

| Task | Command | Notes |
|------|---------|-------|
| **Install vcluster CLI** | `curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64" && chmod +x vcluster && sudo mv vcluster /usr/local/bin/` | Check releases for your OS |
| **Create local vcluster** | `vcluster create my-cluster --namespace vcluster-my-cluster` | Creates namespace + virtual cluster in host |
| **Connect to vcluster** | `vcluster connect my-cluster --namespace vcluster-my-cluster` | Merges kubeconfig; terminal uses vcluster context |
| **List vclusters** | `vcluster list --namespace vcluster-my-cluster` | Shows running virtual clusters |
| **Delete vcluster** | `vcluster delete my-cluster --namespace vcluster-my-cluster` | Removes cluster + namespace |
| **Expose vcluster service** | `kubectl port-forward -n vcluster-my-cluster svc/my-cluster 8443:443` | Access vcluster API from local machine |
| **Get vcluster kubeconfig** | `vcluster connect my-cluster --namespace vcluster-my-cluster --print-kubeconfig` | Export standalone kubeconfig file |

---

## Common Setup Clarifications

### "Host Cluster" = Your Control Plane

When vcluster docs say "host cluster," they mean:
- **Locally:** Docker Desktop's built-in Kubernetes (enable in Settings)
- **Cloud:** Your GKE, EKS, or AKS cluster  
- **CI/CD:** A lightweight host cluster (e.g., k3d, EKS-on-EC2, GKE Autopilot)

You don't create a separate "host cluster"—you use an existing one. If you only have Docker Desktop, that's your host.

vcluster always needs a host—it's lightweight because it **doesn't replicate infrastructure, only Kubernetes API**.

---

## Core Patterns

### Pattern 1: Local Multi-Cluster Testing (Docker Desktop)

**Goal:** Run multiple isolated vcluster instances for testing cross-cluster communication.

**Setup:**
1. Host cluster: Docker Desktop's built-in Kubernetes (enable in Settings)
2. Create N vclusters in separate namespaces
3. Port-forward each vcluster API to unique local port
4. Deploy test workloads to each vcluster
5. Configure cross-cluster network policies or federation

**Configuration Strategy:**
```yaml
# vcluster values override (pass to --values-file or --set flags)
syncer:
  extraArgs:
    - --log-level=info

# Enable API server metrics for debugging
controlPlane:
  distro: k3s
  k3s:
    image: rancher/k3s:v1.28.0
```

**When this works:**
- Testing Kubernetes API against multiple isolated clusters
- Validating namespace isolation and RBAC across clusters
- Simulating failover or load-balancing patterns

**When this breaks:**
- Hardware affinity testing (all pods run on same Docker Desktop VM)
- Large-scale networking (pod-to-pod latency across vclusters differs from production)
- Storage replication (each vcluster has its own storage; no cross-cluster PV access)

---

### Pattern 2: Cloud-Based vcluster (GCP, AWS, Azure)

**Goal:** Deploy vcluster to a managed Kubernetes cluster (GKE, EKS, etc.) for consistent testing across local and cloud environments.

**Architecture:**
1. Host cluster: GKE cluster (or EKS/AKS)
2. vcluster runs as Deployment + StatefulSet in host cluster
3. Multiple vclusters share host's networking, storage, and observability
4. Each vcluster gets its own namespace, API endpoint, and kubeconfig

**Setup (GKE example):**
```bash
# 1. Create host GKE cluster
gcloud container clusters create vcluster-host \
  --zone=us-central1-a \
  --machine-type=n1-standard-2 \
  --enable-stackdriver-kubernetes

# 2. Install vcluster CLI
curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64"
chmod +x vcluster && sudo mv vcluster /usr/local/bin/

# 3. Create vcluster in host
vcluster create staging-cluster \
  --namespace vcluster-staging \
  --host gke \
  --context gke_PROJECT_ZONE_CLUSTER_NAME

# 4. Connect & deploy test workloads
vcluster connect staging-cluster --namespace vcluster-staging
kubectl apply -f test-deployment.yaml
```

**Configuration for cloud (mirroring local setup):**
```yaml
# values.yaml — use for both local and cloud
syncer:
  extraArgs:
    - --log-level=info

controlPlane:
  distro: k3s  # Or "k8s" for vanilla Kubernetes
  k3s:
    image: rancher/k3s:v1.28.0

# Cloud-specific: enable observability
# Integration with Cloud Logging, Cloud Trace, Cloud Monitoring
isolation:
  enabled: true
  namespace: vcluster-staging
```

**Why this works:**
- Identical vcluster configs work on Docker Desktop AND GKE
- Validate workload behavior before production deployment
- Debug workload issues in cloud environment with full observability
- Test GCP integrations (Cloud SQL Proxy, Artifact Registry) in realistic environment

**Why this breaks:**
- Workload Identity, Config Connector don't work in vcluster (requires real GKE service accounts)
- vcluster's scheduler differs from GKE's (advanced scheduling policies may behave differently)
- Cloud-native features (VPC-native networking, security policies) are host-managed, not vcluster-managed

---

### Pattern 3: Testing Kubernetes API & Workload Portability

**Goal:** Validate YAML manifests and Kubernetes primitives without cloud-specific features.

**Strategy:**
1. Write manifests targeting vcluster (no cloud-specific APIs)
2. Test locally on vcluster (5-second feedback loop)
3. Promote same manifests to GKE for cloud integration testing
4. Use same vcluster config across environments

**Manifest Example (works on both vcluster and GKE):**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: postgresql://postgres:5432/mydb

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
      - name: app
        image: gcr.io/my-project/app:latest
        env:
        - name: DATABASE_URL
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: database_url
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: app-service
spec:
  selector:
    app: app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: LoadBalancer
```

**Validation Checklist:**
- ✓ ConfigMaps and Secrets work identically
- ✓ Deployment replicas, resource requests/limits enforced
- ✓ Service networking and DNS resolution
- ✓ RBAC policies and ServiceAccount bindings
- ✓ PersistentVolumeClaims (local provisioner)
- ✗ Workload Identity (GKE-specific)
- ✗ GPU/TPU node affinity (no hardware nodes in vcluster)
- ✗ Network policies (different control plane)

---

## Runnable Example: Local Multi-Cluster Dev Setup

**Scenario:** You're developing a multi-cluster application. You want to rapidly iterate locally on two isolated vclusters without waiting for GKE provisioning.

**Step 1: Set up host cluster (Docker Desktop)**

```bash
# Enable Kubernetes in Docker Desktop Settings
# Verify:
kubectl cluster-info

# Expected output:
# Kubernetes control plane is running at https://127.0.0.1:6443
# CoreDNS is running at https://127.0.0.1:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

**Step 2: Install vcluster CLI**

```bash
# macOS
brew install vcluster

# Linux
curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64"
chmod +x vcluster && sudo mv vcluster /usr/local/bin/

# Verify
vcluster version
```

**Step 3: Create two isolated vclusters**

```bash
# Create first vcluster
vcluster create cluster-a --namespace vcluster-a
# Expected: 5-10 second setup

# Create second vcluster
vcluster create cluster-b --namespace vcluster-b
# Expected: 5-10 second setup

# Verify both are running
vcluster list --namespace vcluster-a
vcluster list --namespace vcluster-b
```

**Step 4: Deploy test workload to cluster-a**

```bash
# Connect to cluster-a
vcluster connect cluster-a --namespace vcluster-a

# Create a test namespace
kubectl create namespace app-test

# Deploy a simple nginx service
kubectl apply -n app-test -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-a
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service-a
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: LoadBalancer
EOF

# Verify deployment
kubectl get pods -n app-test
kubectl get svc -n app-test

# Access service (if LoadBalancer is available)
kubectl port-forward -n app-test svc/nginx-service-a 8080:80 &
# Then: curl http://localhost:8080
```

**Step 5: Deploy test workload to cluster-b**

```bash
# In a new terminal, connect to cluster-b
vcluster connect cluster-b --namespace vcluster-b

# Deploy same workload
kubectl create namespace app-test
kubectl apply -n app-test -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-b
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service-b
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: LoadBalancer
EOF

# Verify deployment in cluster-b
kubectl get pods -n app-test
kubectl get svc -n app-test
```

**Step 6: Deploy with Helm (alternative pattern)**

```bash
# Helm deployments work identically in vcluster
vcluster connect cluster-a --namespace vcluster-a

helm repo add stable https://charts.helm.sh/stable
helm repo update

helm install my-nginx stable/nginx-ingress --namespace app-test
helm list --namespace app-test
```

**Step 7: Verify isolation & cleanup**

```bash
# From cluster-a terminal:
kubectl get svc -n app-test
# Should see only nginx-service-a

# From cluster-b terminal:
kubectl get svc -n app-test
# Should see only nginx-service-b

# Cleanup: delete clusters
vcluster delete cluster-a --namespace vcluster-a
vcluster delete cluster-b --namespace vcluster-b
# Expected: 2-3 seconds each
```

**Total time: 30 seconds for full setup + testing. Contrast with k3d: 6-10 minutes for two clusters.**

---

## Common Mistakes & Fixes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| **Missing parent cluster** | `vcluster create` returns "no cluster connection" | Enable Kubernetes in Docker Desktop, or connect to GKE/EKS first (`kubectl cluster-info`) |
| **Wrong namespace for vcluster** | `vcluster list` shows no clusters; pods missing | vcluster stores namespace in `vcluster-{name}`; use `vcluster list --namespace vcluster-{name}` |
| **LoadBalancer service pending** | `kubectl get svc` shows `<pending>` for LoadBalancer | On Docker Desktop, LoadBalancer requires metalLB; use `kubectl port-forward` instead for dev |
| **kubeconfig context pollution** | `kubectl get nodes` shows host cluster nodes | Use `vcluster connect` (isolates context) instead of manually editing kubeconfig; or use `kubectl config use-context` to switch |
| **Cannot reach vcluster API from host machine** | Connection refused on port 443 | Use `kubectl port-forward` to expose: `kubectl port-forward -n vcluster-{name} svc/{name} 6443:443` |
| **DNS resolution fails for services** | Pod cannot resolve `{service}.{namespace}.svc.cluster.local` | vcluster's DNS runs in-cluster; use full FQDN from outside, or exec into pod: `kubectl exec -it {pod} -- sh` |
| **Storage volumes not persisting** | PVC data lost after vcluster restart | vcluster uses host's local provisioner; test persistent storage on real host (GKE StatefulSets, EBS) separately |
| **Image pull errors (private registry)** | `ErrImagePull` for gcr.io, private Docker registry | Create imagePullSecret in vcluster: `kubectl create secret docker-registry gcr-secret --docker-server=gcr.io --docker-username=_json_key --docker-password="$(cat key.json)"` |
| **Workload Identity references undefined** | Pod uses `cloud.google.com/service-account` annotation; fails in vcluster | Workload Identity is GKE-only; test locally without it, then validate on real GKE |
| **Scheduler differences cause pod eviction** | Pod scheduled in vcluster but evicted on GKE | vcluster uses K3s/Vanilla scheduler; GKE's scheduler has different preemption/eviction logic; stage test on real GKE |
| **vcluster not found in CI/CD** | Pipeline runs but `vcluster create` returns "command not found" | vcluster CLI must be installed in CI runner; add install step before vcluster commands (see CI/CD patterns below) |
| **Cannot see vcluster logs from host** | Debugging pod in vcluster is unclear | Use `vcluster connect` to switch context, then `kubectl logs` normally; or use `kubectl logs -n vcluster-{name} -l app.kubernetes.io/name=vcluster` from host |
| **Helm releases disappear after vcluster restart** | Deploy Helm chart, delete + recreate vcluster, chart is gone | Expected—Helm stores releases in vcluster's etcd (ephemeral). Use vcluster's persistent storage mode or redeploy after restart |
| **PVC stuck in Pending** | `kubectl get pvc` shows Pending indefinitely | vcluster uses host's local provisioner; requires available host storage. Check: `kubectl get storageclass` (host context) |

---

## Configuration Networking Patterns

### Exposing vcluster Services Locally

**Pattern: Port-forward from host machine**
```bash
# Expose vcluster API (admin access)
kubectl port-forward -n vcluster-my-cluster svc/my-cluster 6443:443 &

# Expose service from within vcluster
kubectl port-forward -n app-test svc/my-app 8080:80 &

# Usage
curl https://localhost:6443 # vcluster API
curl http://localhost:8080 # vcluster service
```

**Pattern: Use vcluster's embedded kubeconfig**
```bash
# Generate kubeconfig for standalone access
vcluster connect my-cluster --namespace vcluster-my-cluster --print-kubeconfig > vcluster-kubeconfig.yaml

# Use with external tools
kubectl --kubeconfig=vcluster-kubeconfig.yaml get nodes
helm --kubeconfig=vcluster-kubeconfig.yaml install my-chart my-repo/my-chart
```

### Networking Across vcluster Boundaries

**Pattern: Service discovery within vcluster (standard)**
```bash
# From app pod in vcluster
curl http://other-service.other-namespace.svc.cluster.local
# Just works—vcluster's DNS resolves within-cluster names

# From host cluster pod to vcluster service
# Requires explicit port-forward or cross-namespace networking policy
```

**Pattern: Testing cross-cluster communication**
```bash
# Export service endpoints from cluster-a
kubectl port-forward -n vcluster-a svc/service-a 8080:80 &

# From cluster-b pod, reach cluster-a via host's port-forward
# This is limited; for real multi-cluster testing, use service mesh (Istio, Linkerd)
```

---

## Validation: Before Claiming "Works"

**Kubernetes API parity checklist:**
- [ ] Deployments, StatefulSets, DaemonSets scale correctly
- [ ] Services (ClusterIP, NodePort, LoadBalancer) route traffic
- [ ] ConfigMaps and Secrets inject into pods
- [ ] RBAC (Roles, RoleBindings) enforce namespace isolation
- [ ] PersistentVolumeClaims provision and mount
- [ ] HorizontalPodAutoscaler scales based on metrics

**Cloud integration checklist (for GKE/EKS staging):**
- [ ] Same manifests run on vcluster AND real GKE
- [ ] Observability (logs, traces, metrics) visible in cloud provider dashboard
- [ ] Secrets/credentials work (don't assume Workload Identity in vcluster)
- [ ] Network egress rules match production (firewall, NAT gateway)

---

## Real-World Impact

**Scenario: Microservices team using vcluster for rapid iteration**

| Phase | Tool | Time | Cost |
|-------|------|------|------|
| **Local development** | vcluster (2 clusters) | 5s setup, 10s per deploy cycle | Free (Docker Desktop) |
| **Staging validation** | GKE cluster | 3min provisioning, 30s per deploy cycle | $0.50/hour |
| **Production rollout** | GKE production | 0s (already running) | $20+/hour |

**Benefit:** Developers catch 90% of issues locally (fast feedback), stage 9% on real GKE (cloud-specific), deploy 1% to production (confidence).

---

## CI/CD Integration Pattern

**GitHub Actions example:** Testing workloads in vcluster before deploying to GKE

```yaml
name: Test in vcluster, then deploy to GKE

on: [push]

jobs:
  test-in-vcluster:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      # Set up a lightweight host cluster (k3d)
      - name: Install k3d
        run: curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
      
      - name: Create k3d cluster (host for vcluster)
        run: k3d cluster create ci-host --wait
      
      # Install and create vcluster
      - name: Install vcluster CLI
        run: |
          curl -L -o vcluster https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64
          chmod +x vcluster && sudo mv vcluster /usr/local/bin/
      
      - name: Create vcluster for testing
        run: vcluster create ci-test --namespace vcluster-ci
      
      - name: Deploy to vcluster
        run: |
          vcluster connect ci-test --namespace vcluster-ci
          kubectl apply -f kubernetes/manifests/
      
      - name: Run tests in vcluster
        run: |
          kubectl wait --for=condition=available --timeout=300s deployment/app -n app-test
          kubectl logs -n app-test -l app=app
      
      # If tests pass, deploy to real GKE
      - name: Deploy to GKE
        if: success()
        uses: google-github-actions/setup-gcloud@v1
        with:
          service_account_key: ${{ secrets.GKE_SA_KEY }}
      
      - name: Deploy to production GKE
        if: success()
        run: |
          gcloud container clusters get-credentials prod-cluster --zone us-central1-a
          kubectl apply -f kubernetes/manifests/
      
      # Cleanup
      - name: Cleanup vcluster
        if: always()
        run: vcluster delete ci-test --namespace vcluster-ci
```

**Key points:**
- vcluster runs in CI using k3d as host (both lightweight)
- Same manifests tested locally AND in GKE (no rewrite)
- Fast feedback (5 minutes from commit to GKE deployment)
- No cloud resources consumed unless tests pass

---

## References & Further Reading

- **Official docs:** https://www.vcluster.sh/docs/
- **Quick start:** https://www.vcluster.sh/docs/getting-started/setup
- **Cloud deployment:** https://www.vcluster.sh/docs/operator/architecture
- **Troubleshooting:** https://www.vcluster.sh/docs/troubleshooting/common-issues
