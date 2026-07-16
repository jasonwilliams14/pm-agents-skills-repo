# vcluster Cloud Deployment Pattern

## Goal

Deploy vcluster to a managed Kubernetes cluster (GKE, EKS, Azure AKS) for consistent testing across local Docker Desktop and cloud environments. Use identical vcluster configurations to validate workloads locally, then stage on cloud with confidence.

---

## Architecture: Cloud-Based vcluster

```
Cloud Provider (GCP / AWS / Azure)
├── Host Cluster (GKE / EKS / AKS)
│   ├── Namespace: vcluster-staging
│   │   ├── Pod: vcluster-control-plane (API server, etcd)
│   │   ├── Pod: vcluster-syncer (bridges to host)
│   │   ├── Pod: your-app-1 (runs inside virtual cluster)
│   │   ├── Pod: your-app-2
│   │   └── Service: vcluster-staging (exposes API to external tools)
│   ├── Namespace: vcluster-prod
│   │   └── [separate vcluster for production validation]
│   └── Shared: Storage classes, ingress, observability stack
```

---

## Setup Pattern: GKE Example

### Prerequisites

- Existing GKE cluster (or EKS/AKS)
- `kubectl` context pointing to cloud cluster
- `vcluster` CLI installed locally
- Cloud SDK configured (`gcloud auth login`)

### Step 1: Create Host GKE Cluster (if needed)

```bash
# Create a GKE cluster to host vcluster
gcloud container clusters create vcluster-host \
  --zone=us-central1-a \
  --machine-type=n1-standard-2 \
  --num-nodes=2 \
  --enable-stackdriver-kubernetes \
  --enable-ip-alias

# Get credentials
gcloud container clusters get-credentials vcluster-host --zone us-central1-a

# Verify
kubectl cluster-info
```

### Step 2: Install vcluster CLI

```bash
# macOS
brew install vcluster

# Linux
curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64"
chmod +x vcluster && sudo mv vcluster /usr/local/bin/

# Verify
vcluster version
```

### Step 3: Create vcluster in GKE

```bash
# Create vcluster in staging environment
vcluster create staging-cluster \
  --namespace vcluster-staging \
  --values-file ~/.agents/skills/vcluster-dev/templates/values-cloud-gke.yaml

# Verify
vcluster list --namespace vcluster-staging
```

### Step 4: Connect and Deploy

```bash
# Connect to vcluster
vcluster connect staging-cluster --namespace vcluster-staging

# Create namespace for your app
kubectl create namespace app

# Deploy your manifests (same ones tested locally)
kubectl apply -f kubernetes/manifests/

# Verify deployment
kubectl wait --for=condition=available --timeout=300s deployment --all -n app
kubectl get deployments -n app
```

### Step 5: Validate Cloud Integration

```bash
# Check if logs are visible in Cloud Logging
gcloud logging read "resource.type=k8s_pod" --limit 10 --format json

# Check if metrics are in Cloud Monitoring
gcloud monitoring time-series list --filter "metric.type:kubernetes.io/container/cpu"

# Verify service is accessible
kubectl get svc -n app

# Test external access (if LoadBalancer service)
kubectl port-forward -n app svc/my-app 8080:80 &
curl http://localhost:8080
```

---

## Configuration for Cloud (values-cloud-gke.yaml)

See `templates/values-cloud-gke.yaml` for a production-ready configuration.

**Key differences from local:**

| Setting | Local | Cloud |
|---------|-------|-------|
| **Storage class** | local-path | standard-rwo (GKE) |
| **Resources** | 512MB RAM, 1 CPU | 1GB RAM, 2 CPU |
| **Metrics** | Disabled | Enabled (Cloud Monitoring) |
| **Distro** | K3s (lightweight) | K3s (same as local) |
| **RBAC** | Basic | Enforced |

---

## Multi-Cloud: Same Config, Different Clouds

### Deploy to AWS EKS

```bash
# Set EKS cluster context
aws eks update-kubeconfig --name my-eks-cluster --region us-east-1

# Create vcluster in EKS
# Use same K3s version as GKE for consistency
vcluster create staging-cluster --namespace vcluster-staging

# Deploy same manifests
vcluster connect staging-cluster --namespace vcluster-staging
kubectl apply -f kubernetes/manifests/
```

### Deploy to Azure AKS

```bash
# Set AKS cluster context
az aks get-credentials --resource-group my-rg --name my-aks-cluster

# Create vcluster in AKS
vcluster create staging-cluster --namespace vcluster-staging

# Deploy same manifests
vcluster connect staging-cluster --namespace vcluster-staging
kubectl apply -f kubernetes/manifests/
```

**Benefit:** Same `values-cloud-gke.yaml` works across GKE, EKS, AKS because vcluster provides a Kubernetes abstraction layer.

---

## When Cloud vcluster Works

✓ **API parity testing** — Your manifests work identically on vcluster vs real cloud cluster

✓ **Multi-cloud staging** — Validate same code on GCP, AWS, Azure with minimal config changes

✓ **Secrets & configuration** — Test how ConfigMaps/Secrets inject in cloud environment

✓ **Observability integration** — Verify logs/metrics reach Cloud Logging, CloudWatch, Azure Monitor

✓ **Cost-efficient testing** — Small vcluster uses fewer resources than full production cluster

---

## When Cloud vcluster Breaks

✗ **GKE Workload Identity** — vcluster pods can't use Workload Identity (requires real GKE service accounts)

✗ **GCP-native APIs** — Cloud SQL Proxy, GCS, Pub/Sub annotations don't work in vcluster (mock locally, test on real GKE)

✗ **Config Connector** — GCP resources (KMS, Datastore, etc.) not available in vcluster

✗ **Advanced scheduling** — GKE's scheduler preemption policies differ from K3s

✗ **Multi-zone failover** — vcluster runs on single zone (host cluster zone); test multi-zone on real GKE

---

## Real-World Workflow: Local → Cloud → Production

```
Developer Workflow:
───────────────────────────────────────────────────────────────────

1. Local Dev (Docker Desktop vcluster)
   └─ 5-second feedback loop
   └─ Rapid iteration on manifests
   └─ All Kubernetes API tests pass ✓

2. Stage on GKE (cloud vcluster)
   └─ 30-second setup (already provisioned)
   └─ Validate observability integration
   └─ Test image pulls from GCR
   └─ Confirm manifests work in cloud environment ✓

3. Deploy to Production (real GKE)
   └─ Same manifests (already tested locally + stage)
   └─ High confidence — 90% of issues caught earlier
   └─ Rollout with canary / traffic splitting

Total time: 10 min (local) + 5 min (stage) + 5 min (prod rollout)
Confidence: 99% (issues found at cheapest stage, earliest feedback)
```

---

## Cost Comparison

| Environment | Setup Time | Cost | Use Case |
|-------------|-----------|------|----------|
| **Local vcluster** | 5s | Free | Rapid iteration, all devs |
| **Cloud vcluster** (staging) | 30s | ~$5–10/month | Pre-production validation |
| **Production GKE** | 3min | ~$100–500/month | Live traffic |

**Recommendation:** Use cloud vcluster for validation before deploying to prod (catches environment-specific issues at minimal cost).

---

## Troubleshooting Cloud vcluster

### Issue: vcluster stuck in Pending

```bash
# Check if host cluster has resources
kubectl get nodes
kubectl top nodes

# vcluster requires ~1GB RAM on host; ensure available
kubectl describe node node-1
```

### Issue: Image pull fails from GCR

```bash
# Create imagePullSecret in vcluster
vcluster connect staging-cluster --namespace vcluster-staging

kubectl create secret docker-registry gcr-secret \
  --docker-server=gcr.io \
  --docker-username=_json_key \
  --docker-password="$(cat ~/gcloud-key.json)"

# Reference in pod spec
spec:
  imagePullSecrets:
  - name: gcr-secret
```

### Issue: Workload Identity annotation ignored

```bash
# This won't work in vcluster:
spec:
  serviceAccountName: my-sa
  # annotations: cloud.google.com/service-account...  ← Ignored in vcluster

# Solution: Test without WI locally, then validate on real GKE
# On real GKE, WI will work with same ServiceAccount
```

### Issue: Logs not appearing in Cloud Logging

```bash
# Verify Cloud Logging is enabled on GKE cluster
gcloud container clusters describe vcluster-host --zone us-central1-a | grep stackdriver

# Check if pod logs are being collected
kubectl logs -n vcluster-staging -l app.kubernetes.io/name=vcluster

# In Cloud Console: Logs > Kubernetes Cluster > vcluster-staging namespace
```

---

## Next Steps

1. **Deploy to cloud staging** — Run `vcluster create` with cloud values file
2. **Validate manifests** — Deploy same YAML as local testing
3. **Test observability** — Check Cloud Logging, Monitoring dashboards
4. **Promote to prod** — Use cloud-tested manifests for production rollout

---

## Related Documentation

- **Local setup** → `templates/local-multicluster-setup.sh`
- **Cloud values** → `templates/values-cloud-gke.yaml`
- **Networking** → `references/networking-patterns.md`
- **Validation** → `references/validation-checklist.md`
- **Troubleshooting** → `workflows/troubleshooting.md`
