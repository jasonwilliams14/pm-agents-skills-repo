---
name: nginx-patterns
description: Advanced configuration for NGINX Ingress Controller and Gateway Fabric, specializing in Layer 7, API gateway, AI/LLM traffic optimization and agentic routing.
---

# SKILL: NGINX Patterns (NGINX, Ingress Controller + Gateway Fabric)

## Context & Activation
**Activate when:**
* Configuring or troubleshooting **standalone NGINX (OSS/Plus)**, the **NGINX Ingress Controller (NIC)**, or **NGINX Gateway Fabric (NGF)**.
* Tuning **NGINX directives** for specific behaviors like **SSE streaming**, **proxy buffering**, or **upstream retries** (specifically for LLM backends).
* Implementing **agentic traffic routing** or AI-integrated proxy workflows.
* Defining Kubernetes resources such as **NGF HTTPRoute** or NGINX-specific CRDs.
* Enhancing **NGINX observability** and monitoring within a cloud-native stack.

## The Unified Data Plane Architecture
You operate with the understanding that **NGINX Core (OSS/Plus), NIC, and NGF share the same underlying data plane.**
- **Same Logic:** Core NGINX directives (e.g., `proxy_buffering`, `keepalive`, `timeout`) behave identically across all three models.
- **Different Delivery:** The only difference is the *control plane mechanism* used to deliver that config (raw `nginx.conf`, K8s Ingress Annotations, or Gateway API CRDs).
- **Rule:** When configuring for K8s, always map the required NGINX data plane behavior back to the appropriate K8s abstraction (Annotation vs. Policy CRD).

## Core Proficiencies
* **Layer 7/API Gateway:** Expert at Layer 7 routing, reverse proxy, load balancing, caching/CDN.
* **Traffic Engineering:** Logic for modern LLM workloads, long-lived connections, and streaming responses.
* **Gateway Fabric (NGF):** Implementation of the Kubernetes Gateway API using NGF.
* **Performance Optimization:** Tuning proxy buffering and timeouts for AI inference pipelines.
* **Resiliency Patterns:** Upstream retry mechanisms and circuit breakers for AI model providers.
* **NGINX NJS**: Extending advanced logic for NGINX using NJS (JavaScript).

## Response Pattern
Adopt a surgical, demand-driven response style to minimize token bloat:

1.  **Concept clarity**: Lead with a one-paragraph mental model of the NGINX logic.
2.  **Architecture diagram**: Use Mermaid ONLY if the traffic flow through the proxy is complex (e.g., Auth_request or fan-out).
3.  **Config Output**: 
    - For **Inquiries** (e.g., "How does NGINX handle SSE?"): Provide conceptual explanations and small snippets.
    - For **Directives** (e.g., "Configure my LLM upstream"): Provide complete NGINX config blocks. Pull from `templates/` for structural baselines.
4.  **Trade-offs**: Briefly note NIC vs. NGF or buffering vs. streaming trade-offs.

## Strategic Pivot Rules
- **Base LLM Traffic**: If configuring timeouts, buffering, or SSE, pull `templates/nginx-ai-core-config.md`.
- **Model Routing/Guardrails**: If implementing header/path routing or AI Guardrails, pull `templates/nginx-model-routing.md`.
- **Agentic Workloads**: For long-lived agent runs or tool-call routing, pull `templates/nginx-agentic-config.md`.
- **Observability**: For JSON logging or Prometheus metrics, pull `templates/nginx-observability.md`.
- **Troubleshooting**: If diagnosing K8s-based NGINX failures, pivot to `workflows/k8s-troubleshooting.md`.

## NGINX Ingress Controller vs NGINX Gateway Fabric
| Dimension | NGINX Ingress Controller (NIC) | NGINX Gateway Fabric (NGF) |
|---|---|---|
| K8s API | `Ingress` resource | `Gateway API` (HTTPRoute, GRPCRoute) |
| Config model | Annotations + ConfigMap | Gateway / HTTPRoute / policy CRDs |
| AI inference | Limited — no InferencePool native support | ✅ HTTPRoute → InferencePool backendRef |
| Standard | Proprietary (Ingress API) | K8s SIG-Network standard (Gateway API) |

**Rule of thumb:** New AI platform work → use NGINX Gateway Fabric. Existing NIC deployments → migrate to NGF or use NIC with IngressLink.

## Critical NGINX Config for AI / LLM Traffic
Default NGINX timeouts and buffering will kill LLM workloads.
- **Slow to first byte** (TTFT lag)
- **Long-running** (streaming lag)
- **Buffering**: MUST be off for SSE/streaming to prevent chunking delays.

## Common Anti-Patterns to Catch
Flag these proactively:
- `proxy_buffering on` for SSE/streaming endpoints.
- Default `proxy_read_timeout` (60s) for long completions.
- Retrying LLM calls on 5xx (not idempotent, double-charging tokens).
- Missing `keepalive` for high-frequency inference backends.

## Related Skills
- `k8s-sme` — Gateway API, InferencePools, and K8s infrastructure.
- `f5-cis-patterns` — CIS IngressLink pointing at NGINX.
- `f5xc-patterns` — XC fronting NGINX.
