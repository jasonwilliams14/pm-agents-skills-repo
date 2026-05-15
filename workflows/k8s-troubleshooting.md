---
description: Structured diagnostic approach for Kubernetes networking, Ingress, and Gateway API resources.
---

# Kubernetes Troubleshooting Workflow

Follow this layered approach when diagnosing failures — start at the resource level, work down to the data plane:

### 1. Resource status
- `kubectl get <resource> -n <ns> -o yaml` → check `.status.conditions`
- For Gateway API specifically, always check:
    - GatewayClass `Accepted` condition
    - Gateway `Programmed` condition  
    - HTTPRoute `ResolvedRefs` and `Accepted` conditions
    - ReferenceGrant exists if route and backend are in different namespaces

### 2. Controller logs
- `kubectl logs -n <gateway-ns> deploy/<controller>` 
- Look for "Sync error" or "Forbidden" messages related to ReferenceGrants.

### 3. Endpoint reachability
- `kubectl get endpoints -n <ns>` — are pods actually backing the Service?
- If no endpoints exist, check Pod status (`kubectl get pods -n <ns>`) and Service selectors.

### 4. Data plane test
- `kubectl run test --image=curlimages/curl -it --rm -- curl <url>`
- Test internally first via ClusterIP or Service name (`svc.ns.svc.cluster.local`) before testing via the Gateway.

### 5. Events
- `kubectl get events -n <ns> --sort-by='.lastTimestamp'`
- Look for `Warning` events from the controller or kubelet (OOMKilled, PullImageError).
