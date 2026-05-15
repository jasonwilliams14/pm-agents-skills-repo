# NGINX AI Core Configuration (LLM Optimized)

## NGINX OSS / Ingress Controller (NIC)
Core directives to prevent silent failures in long-lived streaming (SSE) connections:

```nginx
# Required NGINX directives for LLM upstreams
upstream llm-backend {
    server vllm-service:8000;
    keepalive 32;                          # reuse connections to vLLM
}

server {
    location /v1/chat/completions {
        proxy_pass http://llm-backend;

        # Timeouts (critical for LLM)
        proxy_connect_timeout   10s;       # fast fail on connection
        proxy_send_timeout      120s;      # time to send the full request
        proxy_read_timeout      120s;      # time to receive full response

        # SSE / Streaming (critical for token streaming)
        proxy_buffering         off;       # MUST be off for SSE
        proxy_cache             off;
        proxy_set_header        Connection '';
        proxy_http_version      1.1;
        chunked_transfer_encoding on;

        # Headers for tracing
        proxy_set_header        X-Request-ID    $request_id;
        proxy_set_header        traceparent     $http_traceparent;

        # Response size
        proxy_max_temp_file_size 0;        # don't buffer to disk
    }
}
```

## NGINX Gateway Fabric (NGF) Equivalent
Using K8s Gateway API and NginxProxy CRD:

```yaml
apiVersion: gateway.nginx.org/v1alpha1
kind: NginxProxy
metadata:
  name: llm-proxy-config
spec:
  upstream:
    keepalive: 32
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: llm-route
spec:
  parentRefs:
  - name: nginx-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /v1
    backendRefs:
    - kind: InferencePool
      name: llm-pool
      port: 8000
    timeouts:
      request: 120s
      backendRequest: 115s
```
