# vcluster Use Cases: Decision Tree

## When to Use vcluster

### ✓ Use vcluster When:

- **Quick local testing** — Standalone mode: `vcluster create dev01` (no parent cluster needed, 10 seconds to ready)
- **Multi-cluster testing** — Test federation, cross-cluster communication, or failover scenarios (10+ isolated clusters on one machine)
- **Rapid iteration** — Spin up/tear down clusters in 5–10 seconds vs k3d's 2–3 minutes
- **Resource constraints** — Each vcluster uses 512MB–1GB RAM; run 20+ clusters on a laptop
- **Multi-tenancy validation** — Test namespace isolation, RBAC policies, or cluster quotas
- **Cloud-parity testing** — Deploy identical vcluster configurations to local Docker, GCP, AWS, or Azure
- **Dependency testing** — Validate workloads against different Kubernetes API versions (vcluster runs K3s, Vanilla K8s, or EKS distros)
- **POC validation before cloud** — Catch 90% of issues locally (5-second feedback), then stage on real GKE

### ✗ When NOT to Use vcluster

- **Production hardware validation** — vcluster can't test GPU scheduling, node affinity, or hardware-specific workloads
- **GKE-specific features** — Workload Identity, Config Connector, GCP-native APIs have no direct equivalent in vcluster (requires staging on real GKE)
- **Performance/load testing** — Pod-level isolation doesn't replicate cluster-scale networking or scheduler behavior
- **Single-cluster dev** — k3d is simpler and faster for one-off testing
- **Minimal overhead preferred** — If you only need one cluster, k3d startup overhead is negligible; vcluster's parent cluster requirement adds complexity

---

## Decision Matrix: vcluster vs Alternatives

| Scenario | vcluster | k3d | Kind | GKE |
|----------|----------|-----|------|-----|
| **Local multi-cluster testing (5+ clusters)** | ✓ Perfect | ✗ Resource intensive | ✗ Resource intensive | ✗ $$ |
| **Single-cluster local dev** | ⚠️ Overkill | ✓ Best | ✓ Best | ✗ $$ |
| **GPU / hardware affinity testing** | ✗ No | ✗ No | ✗ No | ✓ Yes |
| **GKE-specific features (Workload ID)** | ✗ No | ✗ No | ✗ No | ✓ Yes |
| **Fast feedback loop (sec to ready)** | ✓ 5-10s | ⚠️ 2-3min | ⚠️ 4-6min | ✗ 3-5min |
| **Production-like networking** | ✓ Pod network | ✓ Container network | ✓ Container network | ✓ VPC native |
| **Rapid cluster turnover** | ✓ Yes | ⚠️ Slow | ⚠️ Slow | ✗ Too slow |
| **Cloud-parity (same config locally + GCP)** | ✓ Yes | ⚠️ Differences | ⚠️ Differences | N/A |

---

## Real-World Workflow: Microservices Team

```
Local development     →  Staging validation     →  Production rollout
─────────────────────────────────────────────────────────────────────
vcluster (2 clusters)    GKE cluster              GKE production
5s setup                 3min provisioning        0s (already running)
10s per deploy cycle     30s per deploy cycle     monitored rollout
Free (Docker Desktop)    $0.50/hour              $20+/hour

Result: Developers catch 90% of issues locally (fast feedback),
        stage 9% on real GKE (cloud-specific validation),
        deploy 1% to production (high confidence).
```

---

## vcluster Modes: Standalone vs. With Parent Cluster

### Standalone Mode (No Parent Needed)

**Simple usage:**
```bash
vcluster create dev01
# That's it. Cluster is ready in ~10 seconds.
```

vcluster manages everything directly via Docker. No parent Kubernetes cluster required.

**Best for:** Local testing, rapid iteration, development.

### With Parent Cluster (Optional)

If you want vcluster to run inside an existing Kubernetes cluster:

```bash
# Your host cluster options:
# - Docker Desktop's built-in Kubernetes
# - k3d cluster
# - GKE, EKS, AKS
# - Any running Kubernetes cluster

# Then create vcluster inside it:
vcluster create staging --namespace vcluster-staging
```

**Best for:** Cloud staging, multi-cluster federation, advanced isolation scenarios.

---

## Recommended Reading Order

1. **Uncertain about choice?** → Read this file (you're here)
2. **Need architecture details?** → `references/architecture-comparison.md`
3. **Ready to set up?** → `templates/local-multicluster-setup.sh`
4. **Deploying to cloud?** → `workflows/cloud-deployment.md`
5. **Something's broken?** → `workflows/troubleshooting.md`
