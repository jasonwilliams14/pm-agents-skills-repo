# Success Metrics & OpenTelemetry (OTEL)

No PRD or feature is complete without a Success Metrics section that includes OTEL implementation details.

## Success Metrics Principles
- **Quantitative:** Measurable via data.
- **Qualitative:** User feedback or sentiment.
- **Leading vs. Lagging:** Track both early indicators and final outcomes.

## OTEL Implementation
Every feature must define:
- **Traces:** Specific spans to track user journeys.
- **Metrics:** Counters, Gauges, or Histograms (e.g., `feature_usage_count`).
- **Logs:** Contextual information for debugging.
- **Attributes:** Common tags for filtering (e.g., `user_tier`, `region`).
