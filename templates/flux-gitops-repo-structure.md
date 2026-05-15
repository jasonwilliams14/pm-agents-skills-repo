# Flux GitOps Repo Structure

Standard directory layout for FluxCD managed clusters:

```
clusters/
└── <cluster-name>/
    ├── infrastructure/
    │   ├── namespace.yaml
    │   ├── helmrepository.yaml
    │   └── helmrelease.yaml
    └── apps/
        ├── namespace.yaml
        ├── gateway.yaml
        ├── httproute.yaml
        └── kustomization.yaml
```
