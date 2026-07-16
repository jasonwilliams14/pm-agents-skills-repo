---

## Summary

### **Recommendation: k3d (Primary) + vcluster (Secondary)**

**For your team's needs (fast turnover, low resource, GKE parity), use k3d as your primary tool.**

#### Why k3d:
1. **Fast turnover:** 10-15 seconds vs Kind's 20-30s
2. **Resource efficient:** 1-2 GB RAM/cluster vs Kind's 2-4 GB
3. **Excellent GKE parity:** Vanilla K8s API, same networking/ingress/service patterns
4. **Production-like:** Real scheduler with resource enforcement, VM-level isolation via Docker

#### Why NOT Kind:
- Same API fidelity as k3d, but costs 2-4x more resources—not worth the trade-off for dev

#### vcluster's unique value (but secondary):
- **Pod-level isolation** allows 10+ virtual clusters on single node
- **Fastest turnover** (~5-10s)
- **Lowest resource cost** (512MB-1GB per cluster)
- **Trade-off:** Less cloud parity than k3d (different scheduler/networking model)
  - Use for: parallel test matrices, multi-cluster federation testing, resource-constrained machines
  - **NOT** for production workload validation

### Key Gotchas:
1. **k3s API coverage:** Occasionally omits rare K8s APIs (affects <1% of workloads) → validate your actual workloads once
2. **Storage:** Local path provisioner ≠ GCP Persistent Disks → test PVC behavior separately
3. **Networking:** vcluster shares host network (pod-level isolation), so node-affinity rules behave differently than GKE

I've created a formal ADR at `/tmp/ADR-001-kubernetes-dev-tool-selection.md` for team documentation.

---