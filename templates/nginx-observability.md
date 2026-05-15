# NGINX AI Observability Templates

## Custom JSON log format with AI fields
```nginx
log_format ai_json escape=json
    '{'
    '"timestamp":"$time_iso8601",'
    '"request_id":"$request_id",'
    '"traceparent":"$http_traceparent",'
    '"status":$status,'
    '"upstream":"$upstream_addr",'
    '"request_time":$request_time,'
    '"upstream_response_time":"$upstream_response_time",'
    '"model_tier":"$http_x_model_tier",'
    '"guardrails_decision":"$http_x_guardrails_decision"'
    '}';

access_log /var/log/nginx/ai-access.log ai_json;
```

## NIC ConfigMap — AI-optimized
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-ingress
data:
  proxy-connect-timeout: "10s"
  proxy-read-timeout: "120s"
  proxy-send-timeout: "120s"
  proxy-buffering: "off"
  keepalive: "32"
  log-format: |
    {"time":"$time_iso8601","req_id":"$req_id","status":$status,
     "upstream":"$upstream_addr","rt":$request_time,
     "urt":"$upstream_response_time","traceparent":"$http_traceparent"}
  worker-processes: "auto"
  worker-connections: "16384"
```

## Prometheus Key Metrics for AI Traffic
| Metric | What to watch | Alert threshold |
|---|---|---|
| `nginx_http_request_duration_seconds` | Latency p95 by upstream | > 10s for LLM |
| `nginx_upstream_response_time` | Upstream (model) latency | > 8s p95 |
| `nginx_upstream_connect_time` | Connection pool health | > 100ms = pool exhausted |
