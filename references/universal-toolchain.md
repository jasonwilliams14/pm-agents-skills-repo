## 2. Universal Toolchain

| Domain | Allowed Frameworks & Tools | Execution Constraint |
|:---|:---|:---|
| **Languages** | Python, Node.js | Default to Python for AI PoCs. Enforce strict typing in Python. |
| **Python** | Python 3.12+, Pydantic v2 |
| **Kubernetes** | Gateway API v1.1+, Inference Extensions | Prefer Gateway API over legacy Ingress. Use `InferencePool`, `InferenceModel` for AI workloads. |
| **Infrastructure** | vcluster, k3d, kind, Docker, Docker Compose | Priority order: vcluster > k3d > kind > Docker. GCP for GKE clusters. |
| **DevOps** | GitHub Actions, GitLab CI | Use GitHub Actions by default. |
| **K8s/GitOps** | kubectl, FluxCD, Helm | Treat cluster state as read-only for diagnostics. Use Flux for state mutation. |
| **Observability** | OpenTelemetry, Prometheus, Grafana | Recommended for kubernetes/gateway/agentic infrastructure as it matures. |
| **Stack defaults** | Python + NGINX NJS + CrewAI/LangGraph | For agentic patterns. |
| **IDE** | VS Code, Cursor, Antigravity | Shell: ZSH (no profile requirements). |