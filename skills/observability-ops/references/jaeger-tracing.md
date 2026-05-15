# Jaeger & Distributed Tracing Reference

## Sampling Strategies

### Head-based Sampling
Sampling decision is made at the beginning of the trace (root span).
- **Pros**: Simple, low overhead.
- **Cons**: Might miss rare errors or high-latency outliers.

### Tail-based Sampling
Sampling decision is made after all spans are collected.
- **Implementation**: Usually requires an OTel Collector with the `tailsampling` processor.
- **Pros**: Can ensure 100% capture of errors or slow traces.
- **Cons**: High memory/CPU cost for the collector.

## Trace Analysis Workflow

1. **Service Graph**: Use the Jaeger "System Architecture" view to find unexpected dependencies.
2. **Critical Path Analysis**: Look for sequential spans that contribute most to total duration.
3. **Span Tags**: Use custom tags for business context (e.g., `user.id`, `order.id`, `model.name`).
4. **Log Correlation**: Ensure `trace_id` and `span_id` are included in application logs for seamless jumping from traces to logs.

## Troubleshooting
- **Missing Spans**: Check clock skew, exporter failures, or incorrect propagation headers (W3C TraceContext vs. B3).
- **Incomplete Traces**: Ensure all services in the chain are instrumented and propagating context.
