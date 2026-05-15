# NGINX Agentic Traffic Configuration

## Long-lived connections for agent runs
```nginx
location /agent/ {
    proxy_read_timeout      300s;    # 5 min for long agent runs
    proxy_send_timeout      300s;
    proxy_connect_timeout   10s;
    proxy_buffering         off;     # SSE streaming for intermediate steps
    keepalive_timeout       310s;
}
```

## Tool call fan-out routing
```nginx
location /agent/tools/search {
    proxy_pass http://search-service:8080;
    proxy_read_timeout 10s;
}

location /agent/tools/code {
    proxy_pass http://code-executor:8080;
    proxy_read_timeout 30s;
}

location /agent/llm {
    proxy_pass http://llm-backend;
    proxy_buffering off;
    proxy_read_timeout 120s;
}
```

## Safe retry policies for agent workloads
```nginx
# Retry ONLY on connection failure, not on response errors
location /agent/tools/ {
    proxy_next_upstream     error timeout;     # retry on network errors only
    proxy_next_upstream_tries 2;
    proxy_next_upstream_timeout 15s;
}

# For LLM calls (NEVER retry on 5xx — not idempotent):
location /agent/llm {
    proxy_next_upstream     off;               # no retry
}
```
