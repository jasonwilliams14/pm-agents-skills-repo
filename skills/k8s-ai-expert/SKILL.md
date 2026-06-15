---
name: k8s-ai-expert
description: Expert guidance for deploying and scaling AI/ML workloads on Kubernetes
globs: ["**/*.yaml", "**/*.yml", "**/Dockerfile", "**/helm/**"]
triggers: ["gpu", "cuda", "inference", "llmops", "kserve", "keda", "operator"]
---

# Kubernetes × AI Expert

## Activation Profile
Activate this skill when:
- Deploying AI/ML workloads or LLM inference on K8s.
- Configuring GPU scheduling, node affinity, or tolerations.
- Implementing LLMOps, model serving (vllm/KServe/llm-d/triton), or AI operators.
- Discussion involves autoscaling (KEDA) or vector database orchestration.

---

## Mental Model: K8s as the AI Runtime Fabric

Kubernetes is not just a container orchestrator for AI, it is the **operating system for AI products**:
- **Scheduling** → place GPU pods on the right nodes
- **Operators** → manage the lifecycle of models, fine-tuning jobs, vector DBs
- **KEDA** → autoscale inference based on token queue depth, not just CPU
- **CRDs** → make AI primitives (Model, Prompt, Pipeline) first-class K8s objects
- **Namespaces** → multi-tenant AI workloads with quota isolation
- **Network Policy + Service Mesh** → secure AI service communication

---

# Mental Model: The Local AI Playground
Local clusters are simulated infrastructures within Docker. Efficiency and resource management are paramount:
- Performance: vcluster is generally faster and uses fewer resources than kind for multi-node simulations.
- CPU-Only Inference: Treat CPU as the primary compute; focus on quantized models (GGUF/INT8) to manage system RAM and latency.
- Resource Constraints: hardware always wins; local tools are not infinite and will saturate under heavy LLM loads.

## Operational Directives

### 1. Local Cluster Configuration
- vcluster Setup: Recommend using k8s and vcluster.yaml file 

### 2. Resource Management for AI
- Strict Limits: Always define `cpu` and `memory` limits in manifests to prevent a single local inference pod from crashing the entire Docker host.
- CPU Management: Use Kubernetes CPU Manager for affinity to physical cores if high-performance inference is needed locally.

### 3. Model Optimization
- Quantization: Prioritize recommending 4-bit or 8-bit quantized models to reduce memory footprint.
- Lightweight Engines: Favor local serving engines like Ollama or OpenVINO that are specifically optimized for consumer-grade CPU hardware.

## Quick Reference Commands
- Create k3d cluster: `k3d cluster create dev --servers 1 --agents 2`.
- Create kind cluster: `kind create cluster --config kind-config.yaml`.
- Create vcluster cluster: `vcluster create dev01` or `vcluster create dev01 -f vcluster.yaml`
---

## Core Patterns

### Pattern 1: GPU Node Management
```yaml
# Node selector for GPU workloads
spec:
  nodeSelector:
    accelerator: nvidia-tesla-a100
  tolerations:
  - key: nvidia.com/gpu
    operator: Exists
    effect: NoSchedule
  resources:
    limits:
      nvidia.com/gpu: "1"
    requests:
      nvidia.com/gpu: "1"
```

### Pattern 2: Model Serving (vLLM on K8s)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm-server
  labels:
    app: vllm
    layer: ai
    model: llama-3-8b
spec:
  replicas: 1
  template:
    spec:
      containers:
      - name: vllm
        image: vllm/vllm-openai:latest
        args:
        - --model=meta-llama/Llama-3-8B-Instruct
        - --served-model-name=llama-3-8b
        - --tensor-parallel-size=1
        resources:
          limits:
            nvidia.com/gpu: "1"
            memory: "24Gi"
```

### Pattern 3: KEDA Autoscaling for LLM Inference
Scale inference pods based on **queue depth** or **token throughput**, not CPU.

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: llm-inference-scaler
spec:
  scaleTargetRef:
    name: vllm-server
  minReplicaCount: 1
  maxReplicaCount: 8
  triggers:
  - type: prometheus
    metadata:
      serverAddress: http://prometheus:9090
      metricName: llm_request_queue_depth
      threshold: "10"
      query: sum(llm_pending_requests{service="vllm"})
```

### Pattern 4: Multi-tenant AI with ResourceQuotas
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: ai-quota
  namespace: team-alpha
spec:
  hard:
    requests.nvidia.com/gpu: "2"
    limits.memory: "64Gi"
    # Custom quota for AI (requires quota controller)
    count/modeldeployments.ai.company.io: "3"
```

---

## LLMOps on Kubernetes

### Inference serving stack
```
┌─────────────────────────────────────────────┐
│  AI Gateway (Layer 8)                       │
│  Token budget · Semantic cache · Routing    │
└──────────────┬──────────────────────────────┘
               │
    ┌──────────┼───────────┐
    ▼          ▼           ▼
  vLLM      Triton    External API
 (local)   (local)   (Anthropic/OAI)
```

### Fine-tuning pipeline on K8s
```
Job: data-prep → Job: fine-tune (GPU) → Job: eval → Deployment: serve
      (PVC)          (GPU node)            (CPU)         (GPU/CPU)
```

### Vector DB on K8s
- **pgvector** — Postgres + pgvector extension in a StatefulSet
- **Qdrant** — Kubernetes operator available
- **Weaviate** — Helm chart, production-ready on K8s
- **Chroma** — simple for POCs, limited for production

---

## Observability for AI on K8s

```yaml
# OTel Collector config for AI workloads
receivers:
  otlp:
    protocols:
      grpc: {}
      http: {}

processors:
  # Enrich spans with K8s metadata
  k8sattributes:
    extract:
      metadata: [k8s.namespace.name, k8s.pod.name, k8s.deployment.name]
  
  # Add AI-specific attributes
  attributes:
    actions:
    - key: service.layer
      value: "ai"
      action: insert

exporters:
  prometheus:
    endpoint: "0.0.0.0:8889"
  otlp/tempo:
    endpoint: tempo:4317
```

---

## Key Tools Reference

| Tool | Purpose |
|---|---|
| [vLLM](https://github.com/vllm-project/vllm) | High-throughput LLM inference server |
| [KServe](https://kserve.github.io/) | Serverless model serving on K8s |
| [Kubeflow](https://www.kubeflow.org/) | ML pipeline orchestration |
| [KEDA](https://keda.sh/) | Event-driven autoscaling |
| [Volcano](https://volcano.sh/) | Batch/ML job scheduling on K8s |
| [GPU Operator](https://github.com/NVIDIA/gpu-operator) | NVIDIA GPU management on K8s |
| [Argo Workflows](https://argoproj.github.io/workflows/) | ML/AI pipeline DAGs |

