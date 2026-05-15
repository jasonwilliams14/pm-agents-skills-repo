# Prometheus & Grafana Reference

## PromQL Common Queries

### Error Rate (Percentage)
```promql
sum(rate(http_requests_total{status=~"5.."}[5m])) 
/ 
sum(rate(http_requests_total[5m])) * 100
```

### 99th Percentile Latency
```promql
histogram_quantile(0.99, sum by (le) (rate(http_request_duration_seconds_bucket[5m])))
```

## Alerting Rules

### High Error Rate
```yaml
groups:
- name: app-alerts
  rules:
  - alert: HighErrorRate
    expr: sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) > 0.05
    for: 2m
    labels:
      severity: critical
    annotations:
      summary: "High Error Rate on {{ $labels.instance }}"
```

## Grafana Dashboard Tips
- **Variables**: Use `$service` or `$node` variables to make dashboards dynamic.
- **Annotations**: Overlay deployment events or alert triggers on graphs.
- **Library Panels**: Use shared panels for common metrics like CPU/Memory across multiple dashboards.

## AI Metrics Visualization
- **Panel 1**: Time to First Token (TTFT) Heatmap.
- **Panel 2**: Tokens Per Second (TPS) Gauge.
- **Panel 3**: Cumulative Cost (based on token usage metrics).
