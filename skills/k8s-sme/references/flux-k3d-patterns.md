# FluxCD + k3d Patterns — Deep Reference

## k3d Cluster Setup

### Standard cluster for Gateway API POCs
```bash
# Disable traefik (we manage our own gateway), expose ports 80 and 443
k3d cluster create demo \
  --port "80:80@loadbalancer" \
  --port "443:443@loadbalancer" \
  --k3s-arg "--disable=traefik@server:0" \
  --agents 2

# Verify
kubectl get nodes
kubectl cluster-info
```

### With local registry (for custom images)
```bash
k3d registry create demo-registry --port 5000
k3d cluster create demo \
  --port "80:80@loadbalancer" \
  --port "443:443@loadbalancer" \
  --k3s-arg "--disable=traefik@server:0" \
  --registry-use k3d-demo-registry:5000 \
  --agents 2
```

Push images:
```bash
docker tag myimage:latest k3d-demo-registry:5000/myimage:latest
docker push k3d-demo-registry:5000/myimage:latest
# Use k3d-demo-registry:5000/myimage:latest in manifests
```

### Multi-node for scheduling tests
```bash
k3d cluster create demo \
  --port "80:80@loadbalancer" \
  --port "443:443@loadbalancer" \
  --k3s-arg "--disable=traefik@server:0" \
  --servers 1 \
  --agents 3
```

---

## FluxCD Bootstrap

### Prerequisites
```bash
# Install flux CLI
curl -s https://fluxcd.io/install.sh | sudo bash

# Check prerequisites
flux check --pre
```

### Bootstrap with GitHub
```bash
flux bootstrap github \
  --owner=<github-org-or-user> \
  --repository=<repo-name> \
  --branch=main \
  --path=clusters/<cluster-name> \
  --personal  # omit for org repos
```

This creates the `flux-system` namespace and installs Flux controllers. It also commits the Flux manifests to your repo under `clusters/<cluster-name>/flux-system/`.

### Bootstrap with existing repo (no GitHub token)
```bash
flux bootstrap git \
  --url=ssh://git@github.com/<org>/<repo>.git \
  --branch=main \
  --path=clusters/<cluster-name>
```

---

## Repo Structure (GitOps Layout)

```
clusters/
└── demo/
    ├── flux-system/          # Flux auto-manages this — don't edit manually
    │   ├── gotk-components.yaml
    │   └── gotk-sync.yaml
    ├── infrastructure/       # Controllers, CRDs, shared platform tooling
    │   ├── kustomization.yaml
    │   ├── nginx-gateway/
    │   │   ├── namespace.yaml
    │   │   ├── helmrepository.yaml
    │   │   └── helmrelease.yaml
    │   └── monitoring/
    │       ├── namespace.yaml
    │       ├── helmrepository.yaml
    │       └── helmrelease.yaml
    └── apps/                 # Application workloads
        ├── kustomization.yaml
        └── my-app/
            ├── namespace.yaml
            ├── deployment.yaml
            ├── service.yaml
            └── httproute.yaml
```

---

## HelmRepository

```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: HelmRepository
metadata:
  name: nginx-gateway
  namespace: flux-system
spec:
  interval: 1h
  url: https://helm.nginx.com/stable
```

For OCI registries:
```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: HelmRepository
metadata:
  name: nginx-oci
  namespace: flux-system
spec:
  interval: 1h
  type: oci
  url: oci://ghcr.io/nginx/charts
```

---

## HelmRelease

### NGINX Gateway Fabric
```yaml
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: nginx-gateway-fabric
  namespace: nginx-gateway
spec:
  interval: 1h
  chart:
    spec:
      chart: nginx-gateway-fabric
      version: ">=1.4.0"    # pin a range or exact version
      sourceRef:
        kind: HelmRepository
        name: nginx-gateway
        namespace: flux-system
  install:
    crds: CreateReplace     # install Gateway API CRDs on first install
    createNamespace: true
  upgrade:
    crds: CreateReplace
  values:
    service:
      type: LoadBalancer
    nginxGateway:
      config:
        logging:
          level: info
```

### Kube-Prometheus Stack (monitoring)
```yaml
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: kube-prometheus-stack
  namespace: monitoring
spec:
  interval: 1h
  chart:
    spec:
      chart: kube-prometheus-stack
      version: ">=60.0.0"
      sourceRef:
        kind: HelmRepository
        name: prometheus-community
        namespace: flux-system
  install:
    createNamespace: true
  values:
    grafana:
      enabled: true
      adminPassword: admin  # use valuesFrom for real creds
    prometheus:
      prometheusSpec:
        serviceMonitorSelectorNilUsesHelmValues: false  # pick up all ServiceMonitors
```

### Using valuesFrom for secrets
```yaml
spec:
  valuesFrom:
    - kind: Secret
      name: my-release-values
      valuesKey: values.yaml   # key in the Secret
```

Create the secret:
```bash
kubectl create secret generic my-release-values \
  --from-file=values.yaml=./values-secret.yaml \
  -n flux-system
```

---

## Kustomization (Flux)

### Root kustomization that points to infrastructure
```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: infrastructure
  namespace: flux-system
spec:
  interval: 10m
  sourceRef:
    kind: GitRepository
    name: flux-system
  path: ./clusters/demo/infrastructure
  prune: true
  wait: true   # wait for all resources to be ready before continuing
```

### App kustomization with dependency on infrastructure
```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: apps
  namespace: flux-system
spec:
  interval: 10m
  dependsOn:
    - name: infrastructure    # won't reconcile until infrastructure is ready
  sourceRef:
    kind: GitRepository
    name: flux-system
  path: ./clusters/demo/apps
  prune: true
```

### Kustomization with substitution (environment variables in manifests)
```yaml
spec:
  postBuild:
    substitute:
      CLUSTER_NAME: demo
      DOMAIN: example.com
    substituteFrom:
      - kind: ConfigMap
        name: cluster-vars
```

In manifests, use `${CLUSTER_NAME}` and `${DOMAIN}`.

---

## kustomization.yaml (Kustomize, not Flux)

At the leaf level, every directory needs a `kustomization.yaml`:

```yaml
# clusters/demo/apps/my-app/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - namespace.yaml
  - deployment.yaml
  - service.yaml
  - httproute.yaml
```

Parent directories aggregate children:
```yaml
# clusters/demo/apps/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - my-app/
  - another-app/
```

---

## Flux CLI — Essential Commands

```bash
# Force reconcile everything now (don't wait for interval)
flux reconcile kustomization flux-system --with-source

# Check status of all Flux resources
flux get all -A

# Watch a specific HelmRelease
flux get helmrelease -n nginx-gateway nginx-gateway-fabric -w

# See why something failed
flux describe helmrelease nginx-gateway-fabric -n nginx-gateway

# Suspend reconciliation (useful during debugging)
flux suspend kustomization apps
flux resume kustomization apps

# Tail Flux controller logs
kubectl logs -n flux-system deploy/kustomize-controller -f
kubectl logs -n flux-system deploy/helm-controller -f
```

---

## Common Patterns

### CRD dependency ordering

When HelmRelease B requires CRDs installed by HelmRelease A:
```yaml
# HelmRelease B
spec:
  dependsOn:
    - name: helmrelease-a
      namespace: flux-system
```

Or use a Flux `Kustomization` with `wait: true` between layers.

### GitRepository for a specific branch/tag
```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: my-app
  namespace: flux-system
spec:
  interval: 1m
  url: https://github.com/my-org/my-app
  ref:
    branch: main   # or: tag: v1.2.3, commit: abc123
```

### Image update automation (auto-update deployment when image changes)
```yaml
apiVersion: image.toolkit.fluxcd.io/v1beta2
kind: ImageRepository
metadata:
  name: my-app
  namespace: flux-system
spec:
  image: ghcr.io/my-org/my-app
  interval: 5m

---
apiVersion: image.toolkit.fluxcd.io/v1beta2
kind: ImagePolicy
metadata:
  name: my-app
  namespace: flux-system
spec:
  imageRepositoryRef:
    name: my-app
  policy:
    semver:
      range: ">=1.0.0"
```

---

## Common Issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| HelmRelease stuck `Reconciling` | Chart not found, or CRDs missing | Check HelmRepository status, `flux describe helmrelease` |
| `ResourceNotFound` in Kustomization | Path wrong, or resource doesn't exist in Git | Check `path`, verify file exists in repo |
| `DependencyNotReady` | `dependsOn` target failed or not ready | Fix the dependency first |
| `prune: true` deleting resources | Resource removed from Git | Expected behavior — add to Git to restore |
| Port not accessible on k3d | Missing `--port` flag on cluster create | Delete and recreate cluster with correct ports |
| Flux can't pull from private repo | SSH key not configured | `flux create secret git` with SSH key |
