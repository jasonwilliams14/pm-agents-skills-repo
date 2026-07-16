# vcluster Networking Patterns

## Exposing vcluster Services Locally

### Pattern: Port-forward from host machine

**Expose vcluster API (admin access):**
```bash
# In host cluster terminal
kubectl port-forward -n vcluster-my-cluster svc/my-cluster 6443:443 &

# Usage
curl https://localhost:6443/api/v1/namespaces --insecure
```

**Expose service from within vcluster:**
```bash
# In vcluster-connected terminal
kubectl port-forward -n app-test svc/my-app 8080:80 &

# Usage from host
curl http://localhost:8080
```

### Pattern: Use vcluster's embedded kubeconfig

**Generate kubeconfig for standalone access:**
```bash
# Export kubeconfig from vcluster
vcluster connect my-cluster --namespace vcluster-my-cluster --print-kubeconfig > vcluster-kubeconfig.yaml

# Use with external tools
kubectl --kubeconfig=vcluster-kubeconfig.yaml get nodes
helm --kubeconfig=vcluster-kubeconfig.yaml install my-chart my-repo/my-chart

# Or set env var
export KUBECONFIG=vcluster-kubeconfig.yaml
kubectl get pods
```

---

## Service Discovery Within vcluster

### In-Cluster Communication (Standard Kubernetes)

```bash
# From app pod in vcluster
kubectl exec -it deployment/app -- sh

# Inside container
curl http://other-service.other-namespace.svc.cluster.local
# Just works—vcluster's DNS resolves within-cluster names
```

**DNS patterns:**
- `service-name` → resolves within same namespace
- `service-name.namespace` → resolves across namespaces
- `service-name.namespace.svc.cluster.local` → fully qualified name

---

## Cross-vcluster Communication

### Pattern: Service Discovery Across Clusters

**Limitation:** vcluster pods exist on the host network but have isolated API servers. Direct pod-to-pod comms between vclusters requires port-forward or network policy.

**Port-forward pattern (development only):**

```bash
# Terminal 1: Connect to cluster-a, expose service
vcluster connect cluster-a --namespace vcluster-a
kubectl port-forward -n app-test svc/service-a 8080:80 &

# Terminal 2: Connect to cluster-b, curl cluster-a
vcluster connect cluster-b --namespace vcluster-b
kubectl run curl-pod --image=curlimages/curl -i --rm --restart=Never -- \
  curl http://host.docker.internal:8080
  # macOS/Windows: host.docker.internal
  # Linux: docker0 gateway IP or --network=host
```

### Pattern: Testing Cross-Cluster Federation

**For multi-cluster scenarios, use a service mesh in production:**

```bash
# vcluster testing is limited for true federation
# Better: Use Istio/Linkerd on real GKE clusters with proper cross-cluster secrets
```

---

## Advanced: Networking from Host Cluster Perspective

### Accessing vcluster Resources from Host

**Host cluster terminal (not vcluster-connected):**

```bash
# List vcluster pods
kubectl get pods -n vcluster-my-cluster

# Logs from vcluster control plane
kubectl logs -n vcluster-my-cluster -l app.kubernetes.io/name=vcluster

# Port-forward to host machine
kubectl port-forward -n vcluster-my-cluster svc/my-cluster 6443:443

# Exec into vcluster's syncer (diagnostics)
kubectl exec -it -n vcluster-my-cluster deployment/my-cluster -- sh
```

### vcluster Syncer Service

The **syncer** is a pod that bridges your app workloads with vcluster's API:
- Syncs resources from virtual cluster → host cluster
- Manages lifecycle of vcluster pods
- Handles networking between vcluster API and app pods

```bash
# Inspect syncer logs for debugging
kubectl logs -n vcluster-my-cluster -l app.kubernetes.io/name=vcluster
```

---

## LoadBalancer Services in Local Development

### Issue: LoadBalancer Pending on Docker Desktop

```bash
# In vcluster
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-lb
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 8080
EOF

# Status shows PENDING forever
kubectl get svc
# NAME        TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)
# nginx-lb    LoadBalancer   10.43.x.x      <pending>     80:32000/TCP
```

**Solution: Use port-forward instead**

```bash
# Instead of LoadBalancer, use ClusterIP + port-forward
kubectl patch svc nginx-lb -p '{"spec":{"type":"ClusterIP"}}'

# Or keep LoadBalancer and use port-forward as workaround
kubectl port-forward svc/nginx-lb 8080:80

# Access
curl http://localhost:8080
```

---

## DNS Troubleshooting

### Issue: Service Resolution Fails

```bash
# Pod cannot resolve service name
$ kubectl exec -it deployment/app -- sh
$ curl http://other-service.default.svc.cluster.local
# curl: (6) Could not resolve host
```

**Diagnosis:**

```bash
# Check if service exists
kubectl get svc

# Check DNS pod
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Test DNS from pod
kubectl run dnstest --image=nicolaka/netshoot -i --rm --restart=Never -- \
  nslookup other-service.default.svc.cluster.local
```

**Fix:**

```bash
# If service doesn't exist, create it
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

# DNS resolution should work now
```

---

## Networking Best Practices for vcluster

1. **Within vcluster:** Use standard Kubernetes service discovery (works perfectly)
2. **Local dev across clusters:** Use port-forward + localhost (simple, limited)
3. **Multi-cluster testing:** Stage on real GKE/EKS with proper networking (production-like)
4. **Production-like multi-cluster:** Use service mesh (Istio, Linkerd) on real clusters
5. **CI/CD integration:** Single vcluster per test run (no cross-cluster comms needed)

---

## Common Patterns by Use Case

| Use Case | Pattern | Tools |
|----------|---------|-------|
| **Local API testing** | Port-forward to localhost | `kubectl port-forward` |
| **Multi-app testing** | Separate namespaces in one vcluster | Standard K8s services |
| **Cross-cluster testing** | Port-forward + curl (dev only) | Netshoot, temporary forwarding |
| **Federation testing** | Stage on real GKE with cross-cluster secrets | Istio, Linkerd |
| **CI/CD** | Single vcluster, test everything in one cluster | vcluster in k3d host |

---

## Related References

- **Validation checklist** → `references/validation-checklist.md`
- **Cloud deployment** → `workflows/cloud-deployment.md`
- **Troubleshooting** → `workflows/troubleshooting.md`
