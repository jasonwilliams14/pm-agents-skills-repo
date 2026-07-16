## Response: Multi-Environment Pressure with vcluster-dev Skill

Using **vcluster-dev skill** to address the user's multi-environment workflow question.

---

### 1. **Docker Desktop Setup Instructions** ✓

**Clear, actionable steps:**

1. **Enable Kubernetes in Docker Desktop:**
   - Settings → Kubernetes → Enable Kubernetes
   - Verify: `kubectl cluster-info`

2. **Install vcluster CLI:**
   ```bash
   brew install vcluster  # macOS
   # Or Linux: download from GitHub releases
   vcluster version  # Verify
   ```

3. **Create local vclusters (5-10s each):**
   ```bash
   vcluster create cluster-dev --namespace vcluster-dev
   vcluster create cluster-staging --namespace vcluster-staging
   ```

4. **Connect & deploy:**
   ```bash
   vcluster connect cluster-dev --namespace vcluster-dev
   kubectl apply -f my-deployment.yaml
   ```

**Why this works:** Docker Desktop's built-in Kubernetes becomes the host cluster. vcluster provisions lightweight pod-level virtual clusters (512MB–1GB each), no VMs needed.

---

### 2. **Networking Configuration for Local vcluster** ✓

**Port-forward pattern for local access:**
```bash
# Expose vcluster API
kubectl port-forward -n vcluster-dev svc/cluster-dev 6443:443 &

# Expose application service
kubectl port-forward -n app-test svc/my-app 8080:80 &

# Usage
curl https://localhost:6443         # vcluster API
curl http://localhost:8080          # vcluster service
```

**Within-vcluster networking:** DNS resolution (`service.namespace.svc.cluster.local`) works identically to production. Services communicate normally.

**Cross-cluster communication (limited):** Pod-to-pod across vclusters requires port-forwarding or service mesh (not native). This is the networking gap.

---

### 3. **API Parity vs. GCP Services** ✓ **CRITICAL DISTINCTION**

The skill clearly separates what transfers and what doesn't:

| Feature | Kubernetes API | GCP Integration | Status |
|---------|---|---|---|
| **Deployments, StatefulSets, DaemonSets** | ✓ | — | **Full parity** |
| **Services, ConfigMaps, Secrets** | ✓ | — | **Full parity** |
| **RBAC, Roles, RoleBindings** | ✓ | — | **Full parity** |
| **Resource requests/limits** | ✓ | — | **Full parity** |
| **PersistentVolumeClaims** | ✓ (local provisioner) | — | **Partial** (test logic, not storage replication) |
| **Workload Identity** | ✗ | ✓ (GKE-specific) | **No parity** — test on real GKE |
| **Config Connector** | ✗ | ✓ (GKE-specific) | **No parity** — requires real GKE |
| **Cloud SQL Proxy, Artifact Registry** | ✗ | ✓ | **No parity** — stage on real GKE |
| **VPC-native networking** | ✗ | ✓ (host-managed) | **No parity** — GKE feature |
| **GPU/TPU node affinity** | ✗ | ✓ | **No parity** — no hardware nodes in vcluster |

**Actionable takeaway:** Write manifests without GCP-specific APIs. Test locally on vcluster (5-second feedback). Promote to GKE for cloud integration validation.

---

### 4. **Practical Workflow: Manifest → Local vcluster → GKE** ✓

**Runnable workflow:**

```bash
### PHASE 1: Local Development (vcluster)
# Setup (30 seconds total)
vcluster create dev --namespace vcluster-dev
vcluster connect dev --namespace vcluster-dev

# Deploy application manifest (works on vcluster)
kubectl create namespace app-test
kubectl apply -n app-test -f - <<EOF
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
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: postgresql://postgres:5432/mydb
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
EOF

# Test locally (10s feedback loop)
kubectl get pods -n app-test
kubectl get svc -n app-test
kubectl logs -n app-test -l app=app

### PHASE 2: Cloud Staging (GKE)
# Same manifest, real GKE
gcloud container clusters create staging --zone=us-central1-a --machine-type=n1-standard-2
kubectl apply -n app-test -f app-manifest.yaml  # Same YAML

# Validate GCP integrations (Workload Identity, Config Connector, etc.)
# Add GCP-specific annotations and features here

### PHASE 3: Production (GKE)
# Deploy same core manifest with production settings
```

**Key insight:** The **core Kubernetes primitives** (Deployments, Services, ConfigMaps, RBAC) are **identical** across vcluster and GKE. GCP integrations are tested separately on real GKE.

---

### 5. **Does vcluster-dev Skill Avoid "Configuration Gotchas Without Strategy"?** ✓ **YES**

**Gotchas the skill addresses:**

1. **"We don't know what works locally vs. on GKE"**
   → Skill provides explicit parity checklist: Kubernetes API ✓, GCP services ✗

2. **"Local setup is complex and slow"**
   → Skill shows 30-second multi-cluster setup vs. k3d's 6-10 minutes

3. **"We test locally but deploy differently to GKE"**
   → Skill shows "same manifest" workflow: vcluster → GKE (no rewrite needed)

4. **"Networking configuration is unclear"**
   → Skill explains port-forward pattern, within-vcluster DNS, and cross-cluster limitations

5. **"We don't know what to test where"**
   → Skill validation checklist separates Kubernetes API tests (local vcluster) from GCP integration tests (real GKE)

---

## Acceptance Report