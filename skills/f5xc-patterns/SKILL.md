---
name: f5xc-patterns
description: Expertise in F5 Distributed Cloud (XC), covering multi-cloud networking, AI security at the edge, App Connect, and XC CE on Kubernetes.
---

# SKILL: F5 Distributed Cloud Patterns

F5 XC is a **SaaS-delivered security, networking, and application delivery platform**
that operates across clouds, on-prem, and edge sites from a single control plane.

In our context, XC plays three distinct roles:

| Role | What it does | Relevant to |
|---|---|---|
| **Security perimeter** | WAF, bot protection, DDoS, API abuse at the edge | All AI-facing services |
| **Multi-cloud fabric** | App Connect, virtual networks, service discovery | Connecting K8s clusters |
| **API Gateway** | Auth, rate limiting, versioning, developer portal | LLM API management |

---

## Core Concepts

### Regional Edge (RE) vs Customer Edge (CE)
- **RE** — F5-managed PoPs distributed globally. Traffic enters here first. WAF, DDoS, bot protection run here.
- **CE** — Software deployed in your environment (K8s cluster, VM, bare metal). Bridges your infrastructure to the XC fabric.
- **CE on K8s** — Deploy XC CE as a pod/daemonset in your K8s cluster. Cluster joins the XC fabric, services become reachable globally through XC REs.

### Virtual Networks and App Connect
- **Virtual Network** — an overlay network spanning sites (K8s clusters, clouds, on-prem)
- **App Connect** — service-level connectivity; expose a K8s service to another site without VPN or peering
- **Use case** — AI inference cluster in private K8s connected to GPU-constrained apps in AWS, without public internet exposure

### XC API Gateway
- Auth: API keys, JWT, OAuth2, mTLS
- Rate limiting: request/s, token budget (for AI endpoints)
- Versioning: route by path or header to different backend versions
- AI-specific policies: prompt size limits, response streaming controls, model endpoint firewall

---

## AI Security Patterns with F5 XC

### WAF for LLM endpoints
Standard OWASP rules + AI-specific custom rules:
- Block requests with suspiciously large `messages` arrays (prompt injection attempts)
- Rate limit by `model` field in request body (prevent model-specific abuse)
- Detect and block base64-encoded prompt injection in JSON bodies
- Alert on repeated 400/429 patterns from a single IP (probing)

```yaml
# XC WAF App Firewall — AI endpoint custom rule (conceptual)
name: block-large-prompt-injection
rule_type: custom
condition:
  request_body_match:
    path: "$.messages[*].content"
    condition: length_gt
    value: 50000           # >50KB prompt = suspicious
action: block
response_code: 400
```

### Bot protection for AI APIs
LLM APIs attract scraping, credential stuffing for API keys, and automated probing:
- Enable XC Bot Defense on `/v1/messages`, `/v1/chat/completions` paths
- Configure human vs. bot scoring thresholds (AI APIs don't need browser-level checks)
- Rate limit by API key + IP combination for burst detection

### DDoS and token-aware rate limiting
Standard DDoS protection + AI-specific layer:
- Rate limit by number of requests AND estimated token count in request body
- Progressive rate limiting: soft limit → 429 → hard block → IP block
- Per-model limits: GPT-4 / claude-opus endpoints rate-limited more aggressively

---

## Multi-cloud Connectivity Patterns

### Pattern: Private AI inference across clouds
```
AWS (app cluster)              GCP (GPU inference cluster)
    │                                    │
    │         F5 XC Virtual Network      │
    └────────────────────────────────────┘
                                         │
                               vLLM inference pods
                               (not publicly reachable)
```

App in AWS calls `http://inference-service.internal.xc` — XC routes through the virtual
network to the GCP cluster without traversing the public internet.

### Pattern: K8s services exposed via XC App Connect
```bash
# vesctl: expose a K8s service through XC
vesctl config apply -f - <<EOF
apiVersion: ves.io/v1
kind: HTTPLoadBalancer
metadata:
  name: llm-inference-lb
  namespace: my-tenant
spec:
  domains: ["inference.myplatform.com"]
  https:
    tls_cert_params: ...
  routes:
  - match:
      prefix: /v1
    route:
      origin_pools:
      - name: k8s-inference-pool
        weight: 100
  waf_policy:
    name: ai-waf-policy
EOF
```

### Pattern: XC + K8s Gateway Inference (end-to-end AI traffic)
```
Client
  ↓
F5 XC RE (WAF + Bot + DDoS + Rate limit)
  ↓
F5 XC CE (on K8s cluster)
  ↓
K8s Gateway API (HTTPRoute → InferencePool)
  ↓
InferenceModel → vLLM pods
```

This is the **reference architecture for secure AI inference** in our lab.
Each layer is responsible for a distinct concern:
- XC RE: perimeter security, global rate limiting
- XC CE: cluster ingress, service mesh bridge
- K8s Gateway: internal L7 routing
- InferencePool: model-aware load balancing and scheduling

---

## API Gateway Patterns for AI

### Token budget enforcement at the edge
XC API GW can enforce token budgets before requests reach K8s:
```
Request → XC API GW
  ├── Check API key quota (requests/min from XC rate limit)
  ├── Check token budget (custom XC plugin or service policy)
  └── If OK → forward to K8s inference cluster
```

### Model routing via XC API GW
Route different clients to different model tiers at the API gateway level:
```
/v1/completions + header X-Model-Tier: premium → claude-opus endpoint
/v1/completions + header X-Model-Tier: standard → claude-haiku endpoint
/v1/completions (default) → llama-3-8b (local, cheap)
```

### Developer portal for AI APIs
XC API GW includes a developer portal for publishing AI API docs, managing API keys,
and providing usage dashboards — useful for internal platform teams.

---

## vesctl Quick Reference

```bash
# Install vesctl
curl -LO https://vesio.blob.core.windows.net/releases/vesctl/$(curl -s \
  https://vesio.blob.core.windows.net/releases/vesctl/latest.txt)/vesctl.linux-amd64.gz
gunzip vesctl.linux-amd64.gz && chmod +x vesctl.linux-amd64 && sudo mv vesctl.linux-amd64 /usr/local/bin/vesctl

# Configure
vesctl config set-server <your-tenant>.console.ves.volterra.io
vesctl config set-credentials --api-key <key> --api-cert <cert>

# Common operations
vesctl get namespace                         # list namespaces
vesctl get http_loadbalancer -n <namespace>  # list LBs
vesctl get app_firewall -n <namespace>       # list WAF policies
vesctl config apply -f manifest.yaml         # apply XC config

# XC CE on K8s (site registration)
vesctl config apply -f - <<EOF
apiVersion: ves.io/v1
kind: Site
metadata:
  name: poc-lab-k8s
  namespace: system
spec:
  type: KubernetesSite
  k8s_cluster_name: poc-lab
EOF
```

---

## F5 XC Terraform Provider

For POCs that need reproducible XC configuration:

```hcl
terraform {
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "~> 0.11"
    }
  }
}

provider "volterra" {
  api_p12_file = var.api_p12_file
  url          = "https://${var.tenant}.console.ves.volterra.io/api"
}

resource "volterra_http_loadbalancer" "ai_lb" {
  name      = "ai-inference-lb"
  namespace = var.namespace
  domains   = ["inference.${var.domain}"]
  # ... WAF, routes, etc.
}
```

---

## POC Ideas (F5 XC)

| ID | POC | Value | Effort |
|---|---|---|---|
| XC-001 | XC WAF protecting vLLM on K8s — block prompt injection | Security | M |
| XC-002 | XC App Connect: private AI cluster accessible from multi-cloud apps | Networking | M |
| XC-003 | XC API GW with token budget enforcement for LLM endpoints | Platform | M |
| XC-004 | XC + K8s Gateway Inference end-to-end reference architecture | Reference | L |
| XC-005 | XC Bot Defense tuned for LLM API scraping patterns | Security | S |
| XC-006 | XC developer portal for internal AI API management | Platform | M |

---

## Related Skills
- `k8s-ai-expert` — K8s patterns that XC connects to
- `layer8-patterns` — AI traffic that XC secures
- `k8s-sme` — K8s Gateway API and InferencePools that XC fronts
- `obs-first` — XC metrics + K8s metrics unified in Grafana