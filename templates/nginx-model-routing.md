# NGINX Model Routing Patterns

## Pattern 1: Header-based model tier routing (NIC)
```nginx
# Route by X-Model-Tier header
map $http_x_model_tier $llm_backend {
    "premium"   "claude-opus-backend";
    "standard"  "claude-haiku-backend";
    default     "local-vllm-backend";
}

server {
    location /v1/messages {
        proxy_pass http://$llm_backend;
        proxy_buffering off;
        proxy_read_timeout 120s;
    }
}
```

## Pattern 2: Path-based model routing (NGF HTTPRoute)
```yaml
rules:
- matches:
  - path:
      type: PathPrefix
      value: /v1/models/claude
  backendRefs:
  - name: anthropic-proxy-svc
    port: 8080

- matches:
  - path:
      type: PathPrefix
      value: /v1/models/llama
  backendRefs:
  - group: inference.networking.x-k8s.io
    kind: InferencePool
    name: llama-pool
    port: 8000
```

## Pattern 3: Auth_request for F5 AI Guardrails
```nginx
server {
    location /v1/ {
        # Call Guardrails before forwarding to model
        auth_request /guardrails-check;
        auth_request_set $guardrails_decision $upstream_http_x_guardrails_decision;

        proxy_set_header X-Guardrails-Decision $guardrails_decision;

        proxy_pass http://llm-backend;
        proxy_buffering off;
        proxy_read_timeout 120s;
    }

    location = /guardrails-check {
        internal;
        proxy_pass              http://f5-guardrails-svc:8080/inspect;
        proxy_pass_request_body on;
        proxy_set_header        Content-Type    $content_type;
        proxy_read_timeout      5s;
    }
}
```
