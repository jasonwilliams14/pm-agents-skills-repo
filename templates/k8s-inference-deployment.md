# Kubernetes Inference Deployment (vLLM + GIE)

Full reference for an end-to-end inference stack with LoRA and Gateway API:

```yaml
# 1. vLLM Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm-server
  namespace: ai-inference
  labels:
    app: vllm-server
spec:
  replicas: 2
  selector:
    matchLabels:
      app: vllm-server
  template:
    metadata:
      labels:
        app: vllm-server
    spec:
      containers:
      - name: vllm
        image: vllm/vllm-openai:latest
        args:
        - --model=meta-llama/Llama-3-8B-Instruct
        - --served-model-name=llama-3-8b-base
        - --port=8000
        - --enable-lora
        - --lora-modules
        - llama-3-8b-lora-finance=/models/finance-lora
        ports:
        - containerPort: 8000
        resources:
          limits:
            nvidia.com/gpu: "1"
            memory: "24Gi"
          requests:
            nvidia.com/gpu: "1"
            memory: "20Gi"

---
# 2. InferencePool
apiVersion: inference.networking.x-k8s.io/v1alpha2
kind: InferencePool
metadata:
  name: llm-pool
  namespace: ai-inference
spec:
  targetPortNumber: 8000
  selector:
    matchLabels:
      app: vllm-server
  extensionRef:
    name: llm-endpoint-picker

---
# 3. InferenceModel (base)
apiVersion: inference.networking.x-k8s.io/v1alpha2
kind: InferenceModel
metadata:
  name: llama-3-8b
  namespace: ai-inference
spec:
  modelName: llama-3-8b-base
  criticality: Standard
  poolRef:
    name: llm-pool

---
# 4. InferenceModel (finance LoRA — Critical)
apiVersion: inference.networking.x-k8s.io/v1alpha2
kind: InferenceModel
metadata:
  name: llama-3-8b-finance
  namespace: ai-inference
spec:
  modelName: llama-3-8b-lora-finance
  criticality: Critical
  poolRef:
    name: llm-pool

---
# 5. HTTPRoute
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: inference-route
  namespace: ai-inference
spec:
  parentRefs:
  - name: ai-gateway
    namespace: gateway-system
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /v1
    backendRefs:
    - group: inference.networking.x-k8s.io
      kind: InferencePool
      name: llm-pool
      port: 8000
```
