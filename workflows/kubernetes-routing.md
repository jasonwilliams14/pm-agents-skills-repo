---
description: 
---

# AI Traffic Routing & Inference Observability Playbook

## 1. Gateway API Ingress Mapping
- **Gateway Configuration:** Deploy or update the core Kubernetes Gateway object (using NGINX Gateway Fabric, kgateway)
- **HTTPRoute Setup:** Configure standard L7 path matching (`/v1/chat/completions`) routing to point directly to the configured `InferencePool` instead of a standard ClusterIP Service.

## 2. Smart Load Balancing & Scheduling
- **Endpoint Picker Binding:** Wire the Endpoint Selection Extension (ESE) or `llm-d` scheduler to the `InferencePool`.
- **Routing Evaluation:** Ensure the routing engine intercepts incoming OpenAI-compatible request payloads via the Body Based Router (BBR) to inspect:
  1. Requested model name / LoRA adapter affinity.
  2. Request criticality (Critical vs. Sheddable).
  3. Real-time target metrics (KV Cache utilization and queue depth).

## 3. Traffic Verification & Telemetry Audit
- **Gateway Extension Scrape:** Verify the Endpoint Picker (EPP) layer is tracking Gateway API Inference Extension metrics:
  - Check `inference_pool_average_kv_cache_utilization` (Gauge) to confirm token-aware scheduling.
  - Audit `inference_extension_flow_control_queue_size` to detect request backpressure.
  - Track `inference_objective_normalized_time_per_output_token_seconds` (ntpot) for model efficiency.
- **Model Server Scrape:** Validate that target pods are properly exposing native vLLM/Triton telemetry to Prometheus:
  - Check `vllm:num_requests_running` and `vllm:gpu_cache_usage_perc`.
- **End-to-End KPI Validation:** Execute automated test queries via curl to measure core application-level latency:
  - **TTFT:** Time to First Token (Streaming lag).
  - **ITL:** Inter-Token Latency (Generation speed).

## 4. Failover & Platform Resiliency
- **Shedding Verification:** Confirm that non-critical requests are gracefully queued or shed when KV cache reaches peak utilization limits.
- **Gateway Fallback:** Ensure that if local cluster capacity is completely exhausted, the higher-level AI Gateway layer gracefully falls back to external model-as-a-service endpoints.