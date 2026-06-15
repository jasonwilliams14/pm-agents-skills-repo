# AI & LLM Observability Reference

## Key AI Metrics

### Token Latency
- **TTFT (Time to First Token)**: Critical for user experience. Measured from request start to the first chunk of the response.
- **TPS (Tokens Per Second)**: Throughput measure. Total tokens / (Response End - First Token Time).

### Resource Utilization
- **KV Cache Usage**: High usage leads to request queuing or eviction.
- **GPU Memory/Compute**: Correlate model performance with hardware saturation.

### Cost & Quality
- **Token Count**: Total input + output tokens per model.
- **Hallucination Rate**: Tracked via feedback loops or automated eval spans.

## Model-Aware Routing Observability

When using an AI Gateway (e.g., F5 XC, NGINX), monitor:
- **Fallback Events**: How often requests failover from a primary model to a secondary.
- **Latency by Model**: Compare performance between different LLMs (e.g., GPT-4 vs. Llama 3).
- **Rate Limit Hits**: Track 429s per model provider.

## OpenTelemetry Instrumentation for AI

### Custom Spans for LLM Calls
```python
with tracer.start_as_current_span("llm_call") as span:
    span.set_attribute("llm.model", "gpt-4")
    span.set_attribute("llm.prompt_tokens", 150)
    # ... call LLM ...
    span.set_attribute("llm.completion_tokens", 250)
```

### Semantic Conventions
Follow the emerging OTel semantic conventions for AI:
- `gen_ai.system`: e.g., "openai", "anthropic"
- `gen_ai.request.model`: e.g., "gpt-4"
- `gen_ai.usage.prompt_tokens`: Integer count
- `gen_ai.usage.completion_tokens`: Integer count
