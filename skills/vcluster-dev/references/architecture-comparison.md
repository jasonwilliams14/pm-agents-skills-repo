# vcluster Architecture & Key Differences

## Isolation Levels Explained

| Aspect | vcluster (Standalone) | vcluster (With Parent) | k3d | Kind |
|--------|----------------------|----------------------|-----|------|
| **Isolation Level** | Docker container | Pod in parent cluster | Docker container | Docker container |
| **Startup Time** | 5–10s | 5–10s | 2–3min | 4–6min |
| **RAM per Cluster** | 512MB–1GB | 512MB–1GB | 2–4GB | 2–4GB |
| **Parallel Clusters** | 20+ on laptop | Depends on parent | 2–3 max | 2–3 max |
| **Parent Cluster Required** | ✗ No | ✓ Yes | ✗ No | ✗ No |
| **Multi-tenancy Testing** | ✓ Good | ✓ Excellent | ✗ Limited | ✗ Limited |
| **Setup Complexity** | Minimal (`vcluster create dev01`) | Requires parent setup | Moderate | Moderate |

---

## How vcluster Works (Technical Deep Dive)

### Mode 1: Standalone (Docker-Only)

**Simplest setup:**

```bash
vcluster create dev01
```

vcluster manages everything directly:

```
Your Machine
├── Docker
│   ├── Container: vcluster-cp-dev01 (control plane + etcd)
│   └── Container: vcluster-node-dev01 (worker node)
```

**Advantage:** No external dependencies. Works on any machine with Docker.

### Mode 2: With Parent Cluster (Optional)

**For advanced scenarios:**

```bash
vcluster create staging --namespace vcluster-staging
```

vcluster runs **inside pods on a host cluster**:

```
Your Machine
├── Parent Cluster (Docker Desktop, GKE, EKS, k3d, etc.)
│   └── Pod: vcluster-control-plane-staging
│       └── Virtual K8s API Server + etcd
│   └── Pod: your-app-in-vcluster-staging
```

You control the **host environment** and deploy **identical vcluster configs** across platforms (local → cloud).

### What vcluster Provides vs. What It Doesn't

**vcluster includes:**
- ✓ Virtual Kubernetes API server (K3s, Vanilla K8s, EKS distro)
- ✓ Virtual etcd (cluster state storage)
- ✓ Virtual kubelet (scheduler, controller manager)
- ✓ Virtual DNS (CoreDNS)
- ✓ Service networking (ClusterIP, NodePort, LoadBalancer)
- ✓ RBAC (Roles, RoleBindings)
- ✓ Persistent storage (using host's local provisioner or cloud PV)

**vcluster does NOT include:**
- ✗ Hardware nodes (GPUs, TPUs, specific CPU architectures)
- ✗ Node affinity or taints/tolerations
- ✗ GKE-specific APIs (Workload Identity, Config Connector)
- ✗ Network policies (different control plane)
- ✗ Cluster autoscaler
- ✗ Advanced scheduler policies (different from host)

---

## Networking Architecture

### Pod-Level vs. VM-Level Isolation

**k3d / Kind:** Each cluster is a Docker container with its own overlay network
```
Host Machine Network
├── k3d Cluster A (Docker container)
│   ├── Private pod network (10.42.x.x)
│   └── Services, Ingress
├── k3d Cluster B (Docker container)
│   ├── Private pod network (10.43.x.x)
│   └── Services, Ingress
```

**vcluster:** Clusters run as pods in the host's network
```
Host Cluster Network
├── Namespace: vcluster-a
│   ├── Pod: vcluster-control-plane-a (runs API server)
│   ├── Pod: app-pod-a (your app)
│       └── Uses host's pod network (same CIDR as all vcluster pods)
├── Namespace: vcluster-b
│   ├── Pod: vcluster-control-plane-b (runs API server)
│   ├── Pod: app-pod-b (your app)
│       └── Uses host's pod network (same CIDR as all vcluster pods)
```

**Impact:**
- vcluster pods see each other on the host network (different from production)
- Service discovery within a vcluster works normally
- Cross-vcluster service discovery requires explicit port-forward or network policy
- More lightweight = faster, less resource intensive

---

## Storage Architecture

### Persistent Volume Provisioning

**vcluster's default:** Uses host cluster's local provisioner
- PVCs created in vcluster map to host's PV storage
- Fast for local testing
- **Data is ephemeral** — if vcluster is deleted, PV is orphaned (unless host has persistent backing)

**For cloud (GKE, EKS):**
- vcluster can use host's cloud storage (GCP Persistent Disks, AWS EBS)
- Each vcluster sees its own storage tier
- Production-like, but different from multi-zone replication

---

## Scheduler Behavior

### vcluster's Scheduler vs. Production

**vcluster uses:**
- K3s lightweight scheduler (if distro=k3s)
- Vanilla Kubernetes scheduler (if distro=k8s)
- **Does NOT use GKE's preemption policies, traffic policies, or workload-aware scheduling**

**When this matters:**
- Pod evictions in GKE due to resource pressure → won't happen in vcluster
- Pod disruption budgets → enforced differently in vcluster
- Advanced scheduling (podAffinity, custom plugins) → may behave differently

**Recommendation:** Test scheduling policies on real GKE if critical to your workload.

---

## Multi-Tenancy & Isolation

### Namespace Isolation

vcluster provides **true Kubernetes isolation** at the namespace level:
- Each vcluster has its own API server, etcd, and kubelet
- RBAC policies are enforced separately per vcluster
- One vcluster's ServiceAccount cannot access another vcluster's resources

```yaml
# In cluster-a
apiVersion: v1
kind: Pod
metadata:
  name: pod-a
  namespace: app-test
---
# In cluster-b
apiVersion: v1
kind: Pod
metadata:
  name: pod-b
  namespace: app-test

# These are DIFFERENT pods in DIFFERENT clusters despite same namespace name
```

### RBAC Testing

vcluster is **excellent for RBAC validation:**
- Create Roles, RoleBindings per vcluster
- Test that ServiceAccounts have correct permissions
- Simulate multi-tenant workloads (each tenant gets its own vcluster)

---

## Cost & Resource Analysis

| Item | vcluster | k3d | Kind | GKE |
|------|----------|-----|------|-----|
| **Laptop (16GB RAM, 8 cores)** | 20 clusters @ ~1GB each | 2 clusters @ ~3GB each | 2 clusters @ ~3GB each | N/A |
| **Cost per cluster** | Shared host resources | Shared Docker resources | Shared Docker resources | $50–200/month |
| **Setup time** | 5s | 2-3min | 4-6min | 3-5min |
| **Teardown time** | 2-3s | 1min | 1min | 5-10min |
| **Best case** | Local rapid iteration | One-off testing | One-off testing | Prod validation |

---

## Distro Choices

vcluster can run different Kubernetes distributions:

| Distro | Use Case | Notes |
|--------|----------|-------|
| **K3s** (default) | Lightweight, API testing | ~30MB binary, minimal overhead |
| **Vanilla K8s** | Production parity | Full upstream features, slightly heavier |
| **EKS Distro** | AWS staging | Matches EKS behavior |

**How to choose:**
- **Local dev:** K3s (faster, simpler)
- **Cloud staging:** Match your production distro (K3s for EKS, vanilla for GKE)

---

## When Architecture Limits Matter

| Scenario | Impact | Mitigation |
|----------|--------|-----------|
| GPU workload testing | ✗ No GPU nodes in vcluster | Stage on real GKE/EKS with GPU nodes |
| Node affinity (specific hardware) | ✗ Single logical "node" (host) | Test only on hardware cluster |
| GKE Workload Identity | ✗ Not supported | Use service account secrets locally, test on real GKE |
| High-throughput networking | ⚠️ Pod network may differ | Run perf tests on real cluster |
| Multi-zone failover | ✗ Single zone (host cluster zone) | Stage on multi-zone GKE/EKS |
| PersistentVolume replication | ✗ No multi-replica PVs | Test on cloud with managed storage |

---

## Recommended Reading

- **Uncertain about choice?** → `references/use-cases.md`
- **Ready to deploy?** → `templates/local-multicluster-setup.sh`
