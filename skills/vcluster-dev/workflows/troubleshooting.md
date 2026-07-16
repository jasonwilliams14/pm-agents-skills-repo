# vcluster Troubleshooting & Diagnostic Runbook

Use this guide when vcluster isn't working as expected. Each section includes symptoms, root causes, and fixes.

---

## Diagnostic Process

### Step 1: Check Host Cluster Health

```bash
# Is host cluster running?
kubectl cluster-info

# Are vcluster pods running?
kubectl get pods -n vcluster-{name}

# Expected: vcluster-control-plane deployment in Running state
# Expected: syncer pod in Running state
```

### Step 2: Check vcluster Connectivity

```bash
# Can you connect?
vcluster connect {name} --namespace vcluster-{name}

# If fails, try direct port-forward
kubectl port-forward -n vcluster-{name} svc/{name} 6443:443 &
```

### Step 3: Check Logs

```bash
# Logs from host cluster perspective (not connected to vcluster)
kubectl logs -n vcluster-{name} -l app.kubernetes.io/name=vcluster

# Logs from vcluster syncer
kubectl logs -n vcluster-{name} deployment/{name}
```

---

## Common Mistakes & Fixes

| Mistake | Symptom | Root Cause | Fix |
|---------|---------|-----------|-----|
| **Missing parent cluster** | `vcluster create` returns "no cluster connection" | Docker Desktop Kubernetes disabled or wrong kubectl context | Enable Kubernetes in Docker Desktop Settings; or `kubectl cluster-info` |
| **Wrong namespace** | `vcluster list` shows no clusters; pods missing | Using `--namespace {name}` instead of `--namespace vcluster-{name}` | Always: `vcluster list --namespace vcluster-{name}` |
| **LoadBalancer pending** | `kubectl get svc` shows `<pending>` for LoadBalancer | Docker Desktop has no LoadBalancer provider (no metallb) | Use NodePort or `kubectl port-forward` instead |
| **kubeconfig pollution** | `kubectl get nodes` shows host cluster nodes after `vcluster connect` | Multiple kubectl contexts active; kubeconfig not isolated | Use `vcluster connect` (isolates context); verify: `kubectl config current-context` |
| **Cannot reach API from host** | Connection refused on port 6443 | vcluster API not exposed locally | Use `kubectl port-forward -n vcluster-{name} svc/{name} 6443:443` |
| **DNS fails in pods** | `nslookup service.namespace.svc.cluster.local` times out | Service doesn't exist or CoreDNS not running | `kubectl get svc` to verify service exists; `kubectl get pods -n kube-system` to check CoreDNS |
| **Storage volumes lost** | PVC data lost after vcluster restart | vcluster uses ephemeral local storage by default | Expected on Docker Desktop; use cloud PVs for persistence |
| **Image pull errors** | `ErrImagePull` for private registry images | imagePullSecret not created in vcluster | Create secret: `kubectl create secret docker-registry...` |
| **Workload Identity errors** | Pod uses `cloud.google.com/service-account` annotation; fails | Workload Identity is GKE-only, not supported in vcluster | Test locally without WI; validate on real GKE separately |
| **vcluster not found in CI/CD** | Pipeline runs but `vcluster create` returns "command not found" | vcluster CLI not in PATH in CI runner | Add install step: `curl ... && chmod +x && sudo mv` |
| **vcluster logs unclear** | Can't see what's happening inside virtual cluster | Logs coming from host cluster, not vcluster perspective | Use `vcluster connect`, then standard `kubectl logs` |
| **Helm releases disappear** | Deploy Helm chart, restart vcluster, chart is gone | Helm state stored in ephemeral vcluster etcd | Expected; redeploy after restart or use vcluster backup |

---

## Error Diagnosis by Symptom

### "command not found: vcluster"

```bash
# Solution: Install vcluster CLI
brew install vcluster  # macOS
# OR
curl -L -o vcluster https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64
chmod +x vcluster && sudo mv vcluster /usr/local/bin/

vcluster version  # Verify
```

---

### "no cluster connection"

```bash
# Diagnosis
kubectl cluster-info

# If fails: Docker Desktop Kubernetes not running
# Fix: Settings > Kubernetes > Enable Kubernetes

# If passes but vcluster create still fails:
# You're connected to wrong cluster
kubectl config current-context
kubectl config get-contexts  # List all contexts

# Switch to correct host cluster
kubectl config use-context docker-desktop
```

---

### "vcluster not found" or "unknown namespace"

```bash
# Symptom: vcluster list returns nothing

# Diagnosis: Wrong namespace argument
vcluster list --namespace vcluster-wrong

# Fix: Always use --namespace vcluster-{name}
vcluster list --namespace vcluster-my-cluster

# Verify vcluster exists in host cluster
kubectl get pods -n vcluster-my-cluster
# Expected: vcluster-control-plane pod in Running state
```

---

### "LoadBalancer EXTERNAL-IP is <pending>"

```bash
# Symptom
kubectl get svc
# NAME              TYPE           EXTERNAL-IP   PORT
# my-service        LoadBalancer   <pending>     8080:31234/TCP

# Cause: Docker Desktop has no metallb or cloud LoadBalancer provider

# Solution 1: Use NodePort instead
kubectl patch svc my-service -p '{"spec":{"type":"NodePort"}}'
kubectl get svc  # Should show port mapping

# Solution 2: Use port-forward
kubectl port-forward svc/my-service 8080:8080 &
curl http://localhost:8080

# Solution 3: Install metallb (advanced)
# Only recommended if LoadBalancer is critical for local testing
```

---

### "curl: Could not resolve host"

```bash
# Symptom: Inside pod, DNS resolution fails
kubectl exec -it deployment/app -- sh
$ curl http://other-service.default.svc.cluster.local
# curl: (6) Could not resolve host

# Step 1: Verify service exists (still in vcluster context)
kubectl get svc
# Check if 'other-service' is listed

# If missing: Create service
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: other-service
spec:
  selector:
    app: other-app
  ports:
  - port: 8080
    targetPort: 8080
EOF

# Step 2: Verify CoreDNS is running
kubectl get pods -n kube-system | grep coredns
# Should show coredns pod(s) in Running state

# Step 3: If CoreDNS crashed, restart it
kubectl rollout restart deployment/coredns -n kube-system

# Step 4: Test DNS again
kubectl run dnstest --image=nicolaka/netshoot -i --rm --restart=Never -- \
  nslookup other-service.default.svc.cluster.local
```

---

### "Pod stuck in ImagePullBackOff"

```bash
# Symptom
kubectl get pods
# NAME              READY   STATUS              RESTARTS
# myapp-xxx         0/1     ImagePullBackOff    0

# Check pod events for error details
kubectl describe pod myapp-xxx

# Expected error message: "Image registry credentials not found" OR "Image not found"

# Step 1: Verify image exists and is accessible
docker pull gcr.io/my-project/my-image:latest
# If fails: Image doesn't exist or credentials missing

# Step 2: Create imagePullSecret
kubectl create secret docker-registry gcr-secret \
  --docker-server=gcr.io \
  --docker-username=_json_key \
  --docker-password="$(cat ~/gcloud-key.json)"

# Step 3: Add imagePullSecrets to pod spec
spec:
  imagePullSecrets:
  - name: gcr-secret
  containers:
  - name: app
    image: gcr.io/my-project/my-image:latest

# Step 4: Redeploy and watch
kubectl rollout restart deployment/myapp
kubectl get pods -w
```

---

### "PersistentVolumeClaim stuck in Pending"

```bash
# Symptom
kubectl get pvc
# NAME           STATUS    VOLUME   CAPACITY
# my-pvc         Pending   <none>   0

# Step 1: Check available storage classes
kubectl get storageclass
# Should show 'local-path' (vcluster default)

# Step 2: Check host cluster storage
kubectl top nodes  # Check available space

# Step 3: Check PVC events
kubectl describe pvc my-pvc
# Look for "no persistent volumes available"

# Step 4: Verify host has disk space
df -h

# Fix: If no space, delete old vclusters or increase host disk
```

---

### "Connection refused: 127.0.0.1:6443"

```bash
# Symptom: Can't connect to vcluster API

# Step 1: Verify vcluster is running (from host context, not vcluster-connected)
kubectl get pods -n vcluster-my-cluster
# Should show vcluster-control-plane pod

# Step 2: Check if pod is healthy
kubectl logs -n vcluster-my-cluster -l app.kubernetes.io/name=vcluster | head -20

# Step 3: Create port-forward
kubectl port-forward -n vcluster-my-cluster svc/my-cluster 6443:443 &

# Step 4: Test connection
curl https://localhost:6443 --insecure
# Should return 403 (forbidden) if API is running; you need auth token

# Step 5: Use vcluster connect instead (handles auth)
vcluster connect my-cluster --namespace vcluster-my-cluster
```

---

### "Workload Identity not working"

```bash
# Symptom: Pod with cloud.google.com/service-account annotation can't access GCP APIs

# This is expected — Workload Identity is GKE-only

# Step 1: Understand the limitation
# vcluster runs on a host cluster (GKE, k3d, Docker Desktop)
# Workload Identity requires GKE service account + workload identity binding
# vcluster's pods are isolated virtual clusters; they don't have WI bindings

# Solution for local testing:
# 1. Create GCP service account JSON key locally
# 2. Mount as Secret in vcluster pod
# 3. Set GOOGLE_APPLICATION_CREDENTIALS env var

kubectl create secret generic gcp-creds \
  --from-file=key.json=/path/to/gcloud-key.json

# Add to pod spec:
spec:
  containers:
  - name: app
    env:
    - name: GOOGLE_APPLICATION_CREDENTIALS
      value: /secrets/key.json
    volumeMounts:
    - name: gcp-creds
      mountPath: /secrets
  volumes:
  - name: gcp-creds
    secret:
      secretName: gcp-creds

# Step 2: Test on real GKE with actual Workload Identity
# Same code, real GKE, will use WI automatically
```

---

### "vcluster takes too long to delete"

```bash
# Symptom: vcluster delete hanging or very slow

# Step 1: Check if pods are terminating
kubectl get pods -n vcluster-my-cluster
# Look for pods with DeletionTimestamp set

# Step 2: Check for finalizers (prevents deletion)
kubectl get pod -n vcluster-my-cluster -o yaml | grep finalizers

# Step 3: Force delete (not recommended, but last resort)
vcluster delete my-cluster --namespace vcluster-my-cluster --force

# Step 4: If still stuck, manually cleanup
kubectl delete namespace vcluster-my-cluster --grace-period=0 --force
```

---

## Diagnostic Commands Cheat Sheet

```bash
# Host cluster perspective (not connected to vcluster)
kubectl get pods -n vcluster-{name}                    # Are vcluster pods running?
kubectl logs -n vcluster-{name} -l app.kubernetes.io/name=vcluster   # What are the logs?
kubectl describe pod -n vcluster-{name} -l app.kubernetes.io/name=vcluster  # Pod details?
kubectl top pod -n vcluster-{name}                     # Resource usage?

# vcluster perspective (after vcluster connect)
vcluster connect {name} --namespace vcluster-{name}
kubectl cluster-info                                   # API running?
kubectl get nodes                                      # Nodes available?
kubectl get pods --all-namespaces                      # All pods in vcluster?
kubectl get events --sort-by='.lastTimestamp'          # Recent events?

# Both perspectives
vcluster list --namespace vcluster-{name}              # Cluster status?
vcluster list --all-namespaces                         # All clusters?
```

---

## When to Escalate

If none of the fixes work, escalate to:

1. **vcluster documentation** — https://www.vcluster.sh/docs/troubleshooting
2. **vcluster GitHub issues** — https://github.com/loft-sh/vcluster/issues
3. **Host cluster support** — GKE/EKS/AKS documentation for underlying issues
4. **Real cluster testing** — If vcluster limitation, test on real GKE/EKS

---

## Related Documentation

- **Quick reference** → `templates/vcluster-cli-quickref.sh`
- **Validation checklist** → `references/validation-checklist.md`
- **Networking patterns** → `references/networking-patterns.md`
