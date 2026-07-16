# vcluster Validation Checklist

Use this checklist before claiming a vcluster setup "works" and is ready for handoff to engineering or staging deployment.

---

## Pre-Flight: Basic Setup

- [ ] vcluster CLI installed and executable (`vcluster version`)
- [ ] Host cluster accessible (`kubectl cluster-info`)
- [ ] Sufficient resources on host (RAM, disk, CPU)
- [ ] vcluster namespace created (`kubectl get ns | grep vcluster-`)
- [ ] vcluster pods running (`kubectl get pods -n vcluster-{name}`)

---

## Kubernetes API Parity Checklist

These validate that your vcluster behaves like production Kubernetes:

### Workload Types
- [ ] **Deployments** scale correctly (`kubectl scale deployment app --replicas=3`)
- [ ] **StatefulSets** maintain identity across restarts
- [ ] **DaemonSets** run on available nodes (expect 1 node in vcluster)
- [ ] **Jobs** complete successfully and clean up
- [ ] **CronJobs** execute on schedule

### Configuration & Secrets
- [ ] **ConfigMaps** inject into pods via environment variables
- [ ] **ConfigMaps** inject into pods via volume mounts
- [ ] **Secrets** (Opaque type) inject correctly
- [ ] **Secrets** (docker-registry type) enable private image pulls
- [ ] **Secrets** (TLS type) work with Ingress

### Networking
- [ ] **Service (ClusterIP)** routes traffic within cluster
- [ ] **Service (NodePort)** exposes ports correctly
- [ ] **Service (LoadBalancer)** type accepted (may show `<pending>` on Docker Desktop)
- [ ] **Endpoints** update when pod replicas scale
- [ ] **Service DNS** resolves (`curl http://service-name.namespace.svc.cluster.local`)
- [ ] **Headless Service** supports StatefulSet discovery

### RBAC & Authorization
- [ ] **Roles** can be created and listed
- [ ] **RoleBindings** bind roles to ServiceAccounts
- [ ] **ServiceAccounts** can be listed and used by pods
- [ ] **ClusterRoles** and **ClusterRoleBindings** (if needed for multitenancy)
- [ ] **Pod Security Policies** (if using K8s <1.25) enforced
- [ ] **Pod Security Standards** (K8s 1.25+) enforced by labels

### Storage
- [ ] **PersistentVolumeClaim** creation succeeds
- [ ] **PersistentVolumeClaim** binds to **PersistentVolume**
- [ ] **Pod** can mount PVC and write files
- [ ] **Data persists** across pod restarts (using same PVC)
- [ ] **StorageClass** available (`kubectl get storageclass`)

### Scaling & Autoscaling
- [ ] **Manual scaling** works (`kubectl scale deployment app --replicas=5`)
- [ ] **HorizontalPodAutoscaler** (if testing) scales based on metrics
- [ ] **VerticalPodAutoscaler** (if testing) recommends resource limits

### Logging & Monitoring
- [ ] **Logs visible** via `kubectl logs` 
- [ ] **Previous logs** accessible after pod restart
- [ ] **Events** tracked (`kubectl get events`)

---

## Cloud Integration Checklist (for GKE/EKS/AKS Staging)

Before promoting from vcluster to real cloud cluster:

### Manifest Portability
- [ ] Same manifests run on vcluster **AND** real GKE without changes
- [ ] No vcluster-specific annotations or labels used
- [ ] No hardcoded Docker Desktop localhost references
- [ ] All images are cloud-accessible (no local Docker socket mounts)

### Observability
- [ ] Logs visible in cloud provider dashboard (Cloud Logging, CloudWatch, etc.)
- [ ] Traces (if instrumented) visible in cloud provider (Cloud Trace, X-Ray, etc.)
- [ ] Metrics (if instrumented) exported to cloud monitoring (Cloud Monitoring, CloudWatch, etc.)

### Credentials & Secrets
- [ ] **Secrets** don't assume Workload Identity (test locally, validate on real GKE)
- [ ] **ServiceAccount tokens** accessible via standard Kubernetes mechanisms
- [ ] **Private image registry secrets** work on both vcluster and cloud cluster
- [ ] **Cloud credentials** (GCP service accounts, AWS IAM roles) tested separately on real cluster

### Network & Firewall
- [ ] **Egress rules** match production (if network policies in place)
- [ ] **Ingress** works with cloud load balancers (LoadBalancer type accepted)
- [ ] **Internal service-to-service** communication matches prod topology

### Cloud-Specific APIs
- [ ] **Workload Identity** behavior documented (not testable in vcluster, test on real GKE)
- [ ] **Config Connector** behavior documented (not testable in vcluster, test on real GKE)
- [ ] **GCP-native APIs** (Cloud SQL Proxy, GCS, Pub/Sub) mocked or tested separately
- [ ] **AWS-native APIs** (RDS, S3, SNS/SQS) mocked or tested separately

---

## Multi-Cluster Testing Checklist

If testing federation or cross-cluster scenarios:

- [ ] **Cluster A** and **Cluster B** both running
- [ ] **Service in Cluster A** accessible from **Cluster B** (via port-forward or explicit network policy)
- [ ] **Namespace isolation** enforced (ClusterA's pods can't see ClusterB's pods)
- [ ] **RBAC differences** validated (if testing multi-tenant access control)
- [ ] **Failover behavior** tested (if one cluster stops, traffic handled gracefully)

---

## Common Validation Failures

| Check | Failure | Root Cause | Fix |
|-------|---------|-----------|-----|
| Service DNS resolution | `nslookup` times out | Service doesn't exist or CoreDNS stopped | Create service, restart CoreDNS pod |
| PVC binding | PVC stuck in Pending | No storage provisioner | Check `kubectl get storageclass`; use default local provisioner |
| LoadBalancer EXTERNAL-IP | Shows `<pending>` | Docker Desktop doesn't have LoadBalancer provider | Use NodePort or port-forward instead |
| Pod image pull | `ErrImagePull` | Private registry or image not found | Create imagePullSecret or use public image |
| RBAC denial | Pod gets `403 Forbidden` | ServiceAccount lacks permissions | Create Role/RoleBinding with correct verbs |
| Egress failure | Pod can't reach external API | Network policy blocks or host firewall | Check NetworkPolicy, test from host cluster |

---

## Validation Runbook

**Quick 5-minute validation:**

```bash
# 1. Create test namespace
kubectl create namespace test-validation

# 2. Deploy test app
kubectl apply -f - -n test-validation <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: test-app
  template:
    metadata:
      labels:
        app: test-app
    spec:
      containers:
      - name: app
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: test-app-svc
spec:
  selector:
    app: test-app
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

# 3. Verify Deployment
kubectl get deployment -n test-validation
# Expected: READY 2/2, AVAILABLE 2/2

# 4. Verify Service
kubectl get svc -n test-validation
# Expected: test-app-svc with CLUSTER-IP assigned

# 5. Test DNS
kubectl run dnstest --image=nicolaka/netshoot -n test-validation -i --rm --restart=Never -- \
  nslookup test-app-svc.test-validation.svc.cluster.local
# Expected: Successful resolution to ClusterIP

# 6. Test service access
kubectl run curltest --image=curlimages/curl -n test-validation -i --rm --restart=Never -- \
  curl http://test-app-svc.test-validation.svc.cluster.local
# Expected: HTTP 200, nginx index.html

# 7. Cleanup
kubectl delete namespace test-validation
```

**If all checks pass:** vcluster is ready for POC workloads.

---

## When to Stop Validating & Escalate

- **GPU/TPU workloads:** vcluster can't test hardware; move to real GKE
- **GKE Workload Identity:** Not supported in vcluster; test on real GKE
- **Multi-zone failover:** Not applicable in vcluster; test on multi-zone GKE
- **Performance under load:** vcluster doesn't replicate production networking; test on real cluster
- **Custom scheduler plugins:** May behave differently; validate on real cluster

---

## Pass/Fail Decision

✓ **Ready for staging** — All API parity checks pass + no cloud-specific features required

✗ **Escalate to real cluster** — Failures in cloud integration, GPU/hardware, or GKE-specific APIs

---

## Related Documentation

- **Setup instructions** → `templates/local-multicluster-setup.sh`
- **Networking patterns** → `references/networking-patterns.md`
- **Troubleshooting** → `workflows/troubleshooting.md`
