---
name: observability-ops
description: Specialized workflows for OpenTelemetry, Prometheus, Grafana, Jaeger, and AI-specific observability (token latency, model-aware routing). Use when setting up instrumentation, debugging traces, or building dashboards for cloud-native and AI applications.
---

# Observability Ops

## Overview

The `observability-ops` skill provides expert guidance for implementing and managing full-stack observability. It focuses on the "three pillars" (metrics, logs, traces) with a specific emphasis on modern Cloud-Native (Kubernetes) and AI-centric monitoring needs.

## Core Capabilities

### 1. OpenTelemetry (OTel) Implementation
- **Instrumentation**: Automatic and manual instrumentation for Python, Go, and Node.js.
- **Collector Configuration**: Designing scalable collector pipelines (receivers, processors, exporters).
- **Deployment**: K8s operator vs. sidecar vs. daemonset patterns.
- *See [otel.md](references/otel.md) for SDK and Collector specifics.*

### 2. Metrics & Dashboards (Prometheus & Grafana)
- **PromQL**: Crafting complex queries for SLIs/SLOs and error rates.
- **Alerting**: Designing high-signal alerts with Alertmanager.
- **Visualization**: Grafana dashboard templates for system and application health.
- *See [prometheus-grafana.md](references/prometheus-grafana.md) for query patterns and templates.*

### 3. Distributed Tracing (Jaeger)
- **Sampling Strategies**: Head-based vs. tail-based sampling.
- **Trace Analysis**: Debugging bottlenecks, high-latency spans, and service dependencies.
- *See [jaeger-tracing.md](references/jaeger-tracing.md) for tracing workflows.*

### 4. AI & LLM Observability
- **Token Metrics**: Monitoring Time to First Token (TTFT), Tokens Per Second (TPS), and cost per request.
- **Model-Aware Routing**: Observability for load balancers routing based on model availability or latency.
- **Prompt/Response Logging**: Secure patterns for OTLP-compatible log exporting of AI interactions.
- *See [ai-observability.md](references/ai-observability.md) for AI-specific monitoring.*

## Workflows

### Setup OTel for a Service
1. Identify the language and framework.
2. Select appropriate SDKs (see [otel.md](references/otel.md)).
3. Define OTLP exporter destination.
4. Verify span/metric arrival in the backend.

### Debugging High Latency
1. Locate the trace in Jaeger.
2. Identify the bottleneck span.
3. Cross-reference with Prometheus metrics (CPU/Memory/Queue depth).
4. Analyze AI-specific metrics (e.g., KV cache hit rate) if applicable.

## Resources
- **References**:
    - [otel.md](references/otel.md): SDK setup and Collector configs.
    - [prometheus-grafana.md](references/prometheus-grafana.md): Dashboards and alerts.
    - [jaeger-tracing.md](references/jaeger-tracing.md): Tracing guides.
    - [ai-observability.md](references/ai-observability.md): AI/LLM metrics.
