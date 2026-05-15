# Kubernetes Manifest Conventions

Standard conventions for generating Kubernetes manifests:

```yaml
# Always include apiVersion, kind, metadata.name, metadata.namespace
# Use app.kubernetes.io/name label for selector consistency
# For Gateway API: always pin gatewayClassName explicitly
# For Flux HelmRelease: always pin chart version, use valuesFrom for secrets
# For k3d: use traefik=false since we manage our own ingress/gateway
```
