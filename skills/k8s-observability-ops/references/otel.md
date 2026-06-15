# OpenTelemetry (OTel) Reference

## SDK Setup

### Python
Use `opentelemetry-distro` for quick setup.
```bash
pip install opentelemetry-distro opentelemetry-exporter-otlp
opentelemetry-bootstrap -a install
```
Execution:
```bash
export OTEL_RESOURCE_ATTRIBUTES="service.name=my-python-service"
export OTEL_EXPORTER_OTLP_ENDPOINT="http://otel-collector:4317"
opentelemetry-instrument python app.py
```

### Go
Manual instrumentation is preferred for Go.
```go
import (
    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
    "go.opentelemetry.io/otel/sdk/resource"
    sdktrace "go.opentelemetry.io/otel/sdk/trace"
    semconv "go.opentelemetry.io/otel/semconv/v1.24.0"
)
```

## Collector Configuration

### Recommended Pipeline
```yaml
receivers:
  otlp:
    protocols:
      grpc:
      http:

processors:
  batch:
  resourcedetection:
    detectors: [env, system]
  memory_limiter:
    check_interval: 1s
    limit_percentage: 75
    spike_limit_percentage: 15

exporters:
  prometheus:
    endpoint: "0.0.0.0:8889"
  otlp/jaeger:
    endpoint: "jaeger:4317"
    tls:
      insecure: true

service:
  pipelines:
    metrics:
      receivers: [otlp]
      processors: [memory_limiter, batch]
      exporters: [prometheus]
    traces:
      receivers: [otlp]
      processors: [memory_limiter, resourcedetection, batch]
      exporters: [otlp/jaeger]
```

## Deployment Patterns
- **Sidecar**: Best for low-latency, pod-specific metadata.
- **DaemonSet**: Most resource efficient for node-level metrics.
- **Operator**: Easiest for managing configurations and auto-instrumentation at scale.
