# Kubernetes Gateway API — Deep Reference

## Resource Hierarchy

```
GatewayClass (cluster-scoped)
  └── Gateway (namespace-scoped)
        ├── HTTPRoute (namespace-scoped)
        ├── GRPCRoute (namespace-scoped)
        ├── TCPRoute (namespace-scoped)
        └── TLSRoute (namespace-scoped)
```

**GatewayClass** — Names the controller implementation (e.g., `nginx`, `cilium`). Cluster-scoped. Usually installed by the controller's Helm chart.

**Gateway** — Defines a load balancer: which ports/protocols to listen on, and which namespaces' routes to accept. Like a virtual server declaration.

**Route resources** — Bind to a Gateway via `parentRefs`, define matching rules and backend services. Can be in a *different namespace* from the Gateway (cross-namespace routing requires `ReferenceGrant`).

**ReferenceGrant** — Explicit permission for a Route in namespace A to reference a Service in namespace B. Without it, cross-namespace references are silently rejected.

---

## Minimal Working Example

```yaml
# 1. GatewayClass (usually pre-installed by controller)
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx
spec:
  controllerName: gateway.nginx.org/nginx-gateway-controller

---
# 2. Gateway
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: demo-gateway
  namespace: gateway
spec:
  gatewayClassName: nginx
  listeners:
    - name: http
      port: 80
      protocol: HTTP
      allowedRoutes:
        namespaces:
          from: All  # or: Same, Selector

---
# 3. HTTPRoute
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: demo-route
  namespace: apps
spec:
  parentRefs:
    - name: demo-gateway
      namespace: gateway  # required when route is in different ns
      sectionName: http   # matches listener name above
  hostnames:
    - "demo.example.com"
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /api
      backendRefs:
        - name: demo-svc
          namespace: apps
          port: 8080
```

---

## HTTPRoute Matching Rules

Rules are evaluated in order. First match wins.

### Path matching
```yaml
matches:
  - path:
      type: Exact        # exact string match
      value: /health
  - path:
      type: PathPrefix   # /api matches /api, /api/v1, etc.
      value: /api
  - path:
      type: RegularExpression
      value: /v[0-9]+/.*
```

### Header matching
```yaml
matches:
  - headers:
      - name: x-model
        value: llama3
        type: Exact      # or: RegularExpression
```

### Query param matching
```yaml
matches:
  - queryParams:
      - name: version
        value: "2"
```

### Method matching
```yaml
matches:
  - method: POST
```

Multiple conditions in one `match` block are ANDed. Multiple `matches` items are ORed.

---

## HTTPRoute Filters

### URL rewrite
```yaml
filters:
  - type: URLRewrite
    urlRewrite:
      hostname: backend.internal
      path:
        type: ReplacePrefixMatch
        replacePrefixMatch: /
```

### Request header modification
```yaml
filters:
  - type: RequestHeaderModifier
    requestHeaderModifier:
      add:
        - name: x-routed-by
          value: gateway
      remove:
        - x-internal-token
```

### Redirect
```yaml
filters:
  - type: RequestRedirect
    requestRedirect:
      scheme: https
      statusCode: 301
```

---

## TLS Configuration

### TLS termination at Gateway (most common)
```yaml
listeners:
  - name: https
    port: 443
    protocol: HTTPS
    tls:
      mode: Terminate
      certificateRefs:
        - name: tls-secret     # kubernetes.io/tls Secret
          namespace: gateway
    allowedRoutes:
      namespaces:
        from: All
```

### TLS passthrough (SNI routing, TLS handled by backend)
```yaml
listeners:
  - name: tls-passthrough
    port: 443
    protocol: TLS
    tls:
      mode: Passthrough
```
Use `TLSRoute` (not HTTPRoute) for passthrough.

---

## ReferenceGrant — Cross-Namespace Access

Required when an HTTPRoute references a Service in a different namespace, OR when a Gateway's TLS cert Secret is in a different namespace.

```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: ReferenceGrant
metadata:
  name: allow-gateway-to-apps
  namespace: apps           # the namespace being accessed
spec:
  from:
    - group: gateway.networking.k8s.io
      kind: HTTPRoute
      namespace: gateway   # the namespace doing the referencing
  to:
    - group: ""
      kind: Service
```

---

## Status Conditions — What to Check

### Gateway conditions
```bash
kubectl get gateway demo-gateway -n gateway -o jsonpath='{.status.conditions}' | jq .
```

| Condition | Meaning |
|-----------|---------|
| `Accepted` | GatewayClass recognized this Gateway |
| `Programmed` | Data plane (NGINX/Envoy) is configured and ready |
| `Ready` (deprecated) | Don't rely on this |

### HTTPRoute conditions
```bash
kubectl get httproute demo-route -n apps -o jsonpath='{.status.parents}' | jq .
```

| Condition | Meaning |
|-----------|---------|
| `Accepted` | Gateway accepted this route |
| `ResolvedRefs` | All backend Services and Secrets resolved successfully |

`ResolvedRefs: False` with reason `BackendNotFound` → Service doesn't exist or ReferenceGrant missing.

---

## NGINX Gateway Fabric Specifics

NGF uses `gateway.nginx.org/nginx-gateway-controller` as controllerName.

### NGF-specific policy resources
```yaml
# Per-route timeout
apiVersion: gateway.nginx.org/v1alpha1
kind: HTTPRoutePolicy  # (check current NGF version — API evolves)
```

### NGF observability
NGF exposes Prometheus metrics at `:9113/metrics`. Wire up a ServiceMonitor:
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: ngf-metrics
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: nginx-gateway
  namespaceSelector:
    matchNames:
      - nginx-gateway
  endpoints:
    - port: metrics
      interval: 30s
```

---

## GRPCRoute

For gRPC services. Requires HTTP/2 on the listener.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GRPCRoute
metadata:
  name: inference-grpc
  namespace: inference
spec:
  parentRefs:
    - name: demo-gateway
      namespace: gateway
  rules:
    - matches:
        - method:
            service: tgi.v1.TextGenerationService
            method: Generate      # optional — omit to match all methods
      backendRefs:
        - name: tgi-svc
          port: 8033
```

---

## Common Pitfalls

| Symptom | Likely cause |
|---------|-------------|
| HTTPRoute `ResolvedRefs: False` | Missing ReferenceGrant, or Service name/port mismatch |
| Gateway `Programmed: False` | Controller not running, or GatewayClass not installed |
| Traffic reaches Gateway but gets 404 | `sectionName` in parentRefs doesn't match listener name |
| Route accepted but no traffic | Listener `allowedRoutes.namespaces` doesn't include route's namespace |
| TLS cert not loading | Secret not in same namespace as Gateway, or missing ReferenceGrant |
| gRPC returns UNIMPLEMENTED | Backend doesn't support HTTP/2, or route service/method wrong |

---

## API Version Reference

| Resource | Stable (v1) | Beta (v1beta1) | Alpha (v1alpha2) |
|----------|-------------|----------------|------------------|
| GatewayClass | v1 | — | — |
| Gateway | v1 | — | — |
| HTTPRoute | v1 | — | — |
| GRPCRoute | v1 | — | — |
| TCPRoute | — | — | v1alpha2 |
| TLSRoute | — | — | v1alpha2 |
| ReferenceGrant | — | v1beta1 | — |

Always check: `kubectl get crd | grep gateway.networking.k8s.io` to confirm installed versions.
